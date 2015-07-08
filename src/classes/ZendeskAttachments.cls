// This class provides functionality to call the Zendesk API to interact with Attachment records
public with sharing class ZendeskAttachments {

	private final ZendeskAPI zapi;

	public ZendeskAttachments(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public String uploadAttachment(String fileName, String fileContentType, Blob fileBody) {
		String zendeskAttachmentToken = null;
		try {
			HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/uploads.json?filename=' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
			req.setHeader('Accept', 'application/json');
			req.setHeader('Content-Type', fileContentType);
			req.setBodyAsBlob(fileBody);
			HttpResponse res = new Http().send(req);

			if (res.getStatusCode() != 201) {
				throw new ZendeskException('Error uploading Attachment (' + res.getStatusCode() + ')');
			}

			// Extract the token from the response
			Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
			if (jsonMap.containsKey('upload')) {
				Map<String, Object> upload = (Map<String, Object>)jsonMap.get('upload');
				zendeskAttachmentToken = (String)upload.get('token');
			}
			else {
				throw new ZendeskException('Unexpected content in response. Could not find "upload"');
			}
		}
		catch(Exception e) {
			throw new ZendeskException('Error uploading attachment: ' + e.getMessage());
		}

		return zendeskAttachmentToken;
	}

	// NOTE: You must use Admin credentials to use this method
	public void deleteAttachment(Integer attachmentId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/attachments/' + String.valueOf(attachmentId) + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Attachment ' + attachmentId + ' (' + res.getStatusCode() + ')');
		}
	}

}
