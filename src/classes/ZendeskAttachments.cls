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
			HttpRequest req = zapi.setupRequest('POST', ZendeskAPI.BASE_PATH + '/uploads.json?filename=' + EncodingUtil.urlEncode(fileName, 'UTF-8'));

			// Set headers
			req.setHeader('Accept', 'application/json');
			req.setHeader('Content-Type', fileContentType);

			// Set body
			req.setBodyAsBlob(fileBody);

			HttpResponse res = h.send(req);
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
		HttpRequest req = zapi.setupRequest('DELETE', ZendeskAPI.BASE_PATH + '/attachments/' + String.valueOf(attachmentId) + '.json');

		HttpResponse res = h.send(req);
		System.debug('deleteAttachment res: ' + res);
		String resBody = res.getBody();
		System.debug('**** res = ' + resBody);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error occurred trying to delete attachment ' + attachmentId);
		}
	}

}
