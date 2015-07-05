// This class provides test coverage for the ZendeskAttachments class
@isTest
private class ZendeskAttachmentsTests {

    public class MockCreateAttachmentResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(201);
            res.setStatus('OK');
            res.setBody('{"upload":{"token":"xXiRHUu3pQrV72Gr7uQ3O7HZo","expires_at":"2014-07-06T22:09:45Z","attachments":[{"url":"https://test.zendesk.com/api/v2/attachments/513041274.json","id":513041274,"file_name":"Archive.zip","content_url":"https://test.zendesk.com/attachments/token/qziILyOZaxTM5ywhUmePdtbJC/?name=Archive.zip","mapped_content_url":"https://test.zendesk.com/attachments/token/qziILyOZaxTM5ywhUmePdtbJC/?name=Archive.zip","content_type":"application/zip","size":41870,"thumbnails":[]}]}}');
            return res;
        }
    }

    public class MockOKResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

    static testMethod void testUploadAttachment() {
        Test.setMock(HttpCalloutMock.class, new MockCreateAttachmentResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskAttachments zattach = new ZendeskAttachments(zapi);
		String attachId = zattach.uploadAttachment('filename.txt', 'fileContentType', Blob.valueOf('asdfasfdasdfasdfasdf'));
        Test.stopTest();

		System.assertNotEquals(null, attachId);
    }

    static testMethod void testDeleteAttachment() {
        Test.setMock(HttpCalloutMock.class, new MockOKResponse());

        ZendeskAPI zapi = new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password);

        Test.startTest();
        ZendeskAttachments zattach = new ZendeskAttachments(zapi);
        zattach.deleteAttachment(123);
        Test.stopTest();

        System.assert(true);
    }
}
