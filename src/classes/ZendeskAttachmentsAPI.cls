// This class provides functionality to call the Zendesk Attachments API
global class ZendeskAttachmentsAPI extends ZendeskResourceBase {

    global class AttachmentWrapper {
        global ZAttachment attachment { get; set; }
    }

    global ZendeskAttachmentsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global ZAttachment getAttachment(Long attachmentId) {
        if (attachmentId == null) { throw new ZendeskException('attachmentId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/attachments/'+attachmentId+'.json');
        AttachmentWrapper resultWrapper = (AttachmentWrapper)JSON.deserialize(zconn.sendRequest(req), AttachmentWrapper.class);
        return resultWrapper.attachment;
    }

    global String uploadAttachment(String fileName, String fileContentType, Blob fileBody) {
        if (String.isBlank(fileName)) { throw new ZendeskException('fileName parameter must not be empty'); }
        if (String.isBlank(fileContentType)) { throw new ZendeskException('fileContentType parameter must not be empty'); }
        if (fileBody == null) { throw new ZendeskException('fileBody parameter cannot be null'); }

        String zendeskAttachmentToken = null;
        try {
            HttpRequest req = zconn.createRequest('POST', '/uploads.json', new Map<String, Object>{'filename'=>urlEncode(fileName)});
            req.setHeader('Content-Type', fileContentType);
            req.setBodyAsBlob(fileBody);
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));

            // Extract the token from the response
            if (responseMap.containsKey('upload')) {
                Map<String, Object> upload = (Map<String, Object>)responseMap.get('upload');
                zendeskAttachmentToken = (String)upload.get('token');
            }
            else {
                throw new ZendeskException('Unexpected content in response. Could not find "upload"');
            }
        }
        catch(Exception e) {
            throw new ZendeskException('Error uploading Attachment: ' + e.getMessage());
        }

        return zendeskAttachmentToken;
    }

    global void deleteAttachment(Long attachmentId) {
        if (attachmentId == null) { throw new ZendeskException('attachmentId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/attachments/'+attachmentId+'.json'));
    }

    global void redactCommentAttachment(Long ticketId, Long commentId, Long attachmentId) {
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }
        if (commentId == null) { throw new ZendeskException('commentId parameter cannot be null'); }
        if (attachmentId == null) { throw new ZendeskException('attachmentId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('PUT', '/tickets/'+ticketId+'/comments/'+commentId+'/attachments/'+attachmentId+'/redact.json', '{}'));
    }
}
