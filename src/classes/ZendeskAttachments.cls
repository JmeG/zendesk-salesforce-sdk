// This class provides common functionality to call the Zendesk API to interact with Attachment records
public with sharing class ZendeskAttachments {

    private final ZendeskAPI zapi;

    public ZendeskAttachments(ZendeskAPI zapi) {
        this.zapi = zapi;
    }

    public String uploadAttachment(String fileName, String fileContentType, Blob fileBody) {
  		String zendeskAttachmentToken = null;
  		try {
  			Http h = new Http();
  			HttpRequest req = zapi.setupRequest('POST', '/api/v2/uploads.json?filename=' + EncodingUtil.urlEncode(fileName, 'UTF-8'));

  			// Set headers
  			req.setHeader('Accept', 'application/json');
  			req.setHeader('Content-Type', fileContentType);

  			// Set body
  			req.setBodyAsBlob(fileBody);

  			HttpResponse res;
  			if (!Test.isRunningTest()) {
  				res = h.send(req);
  			} else {
  				// fake response
  				res = new HttpResponse();
  				res.setStatusCode(201);
  				res.setStatus('OK');
  				res.setBody('{"upload":{"token":"xXiRHUu3pQrV72Gr7uQ3O7HZo","expires_at":"2014-07-06T22:09:45Z","attachments":[{"url":"https://test.zendesk.com/api/v2/attachments/513041274.json","id":513041274,"file_name":"Archive.zip","content_url":"https://test.zendesk.com/attachments/token/qziILyOZaxTM5ywhUmePdtbJC/?name=Archive.zip","mapped_content_url":"https://test.zendesk.com/attachments/token/qziILyOZaxTM5ywhUmePdtbJC/?name=Archive.zip","content_type":"application/zip","size":41870,"thumbnails":[]}]}}');
  			}
  			System.debug('upload res: ' + res);
  			System.debug('upload res body: ' + res.getBody());

  			if (res.getStatusCode() != 201) {
  				throw new ZendeskException(res.getBody());
  			}

  			Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
  			System.debug('jsonMap=' + jsonMap);

  			Map<String, Object> upload = (Map<String, Object>)jsonMap.get('upload');
  			//System.debug('upload: ' + upload);

  			zendeskAttachmentToken = (String)upload.get('token');
  			System.debug('zendeskAttachmentToken: ' + zendeskAttachmentToken);
  		}
  		catch(Exception e) {
  			System.debug('Attachment error: ' + e.getMessage());
  			throw new ZendeskException('Error uploading attachment: ' + e.getMessage());
  		}

  		return zendeskAttachmentToken;
  	}

    // NOTE: You must use Admin credentials to use this method
  	public void deleteAttachment(Integer attachmentId) {
  		Http h = new Http();
  		HttpRequest req = zapi.setupRequest('DELETE', '/api/v2/attachments/' + String.valueOf(attachmentId) + '.json');

  		HttpResponse res;
  		if (!Test.isRunningTest()) {
  			res = h.send(req);
  		} else {
  			// fake response
  			res = new HttpResponse();
  			res.setStatusCode(200);
  			res.setStatus('OK');
  		}

  		System.debug('deleteAttachment res: ' + res);
      String resBody = res.getBody();
  		System.debug('**** res = ' + resBody);

  		if (res.getStatusCode() != 200) {
  			throw new ZendeskException('Error occurred trying to delete attachment ' + attachmentId);
  		}
  	}

}
