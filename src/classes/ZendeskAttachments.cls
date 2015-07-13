// This class provides functionality to call the Zendesk API to interact with Attachment records
public with sharing class ZendeskAttachments {

	private final ZendeskAPI zapi;

	public class ZAttachment {
		public Long id {get; private set;}
		public String name {get; set;}
		public String content_url {get; set;}
		public String content_type {get; set;}
		//public Object[] thumbnails {get; set:}
		public Long size {get; set;}
	}

	private class AttachmentWrapper {
		public ZAttachment attachment {get; set;}
	}


	public ZendeskAttachments(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public String uploadAttachment(String fileName, String fileContentType, Blob fileBody) {
		String zendeskAttachmentToken = null;
		try {
			HttpRequest req = zapi.createRequest('POST', ZendeskAPI.BASE_PATH + '/uploads.json?filename=' + EncodingUtil.urlEncode(fileName, 'UTF-8'));
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

	public void deleteAttachment(Long attachmentId) {
		HttpRequest req = zapi.createRequest('DELETE', ZendeskAPI.BASE_PATH + '/attachments/' + String.valueOf(attachmentId) + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error deleting Attachment ' + attachmentId + ' (' + res.getStatusCode() + ')');
		}
	}

	public ZAttachment getAttachment(Long attachmentId) {
		HttpRequest req = zapi.createRequest('GET', ZendeskAPI.BASE_PATH + '/attachments/' + String.valueOf(attachmentId) + '.json');
		HttpResponse res = new Http().send(req);

		if (res.getStatusCode() != 200) {
			throw new ZendeskException('Error getting Attachment ' + attachmentId + ' (' + res.getStatusCode() + ')');
		}

		AttachmentWrapper resultWrapper = (AttachmentWrapper)JSON.deserialize(res.getBody(), AttachmentWrapper.class);
		return resultWrapper.attachment;
	}

}
