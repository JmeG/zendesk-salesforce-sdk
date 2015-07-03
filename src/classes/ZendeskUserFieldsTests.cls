// This class provides test coverage for the ZendeskUserFields class
@isTest
private class ZendeskUserFieldsTests {

  public class MockUserResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setStatus('OK');
      res.setBody('{ "user_field": { "url": "https://support.zendesk.com/api/v2/user_fields/21778153.json", "id": 21778153, "type": "tagger", "title": "Zendesk Plan", "raw_title": "Zendesk Plan", "description": "", "raw_description": "", "position": 7, "active": true, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Zendesk Plan", "raw_title_in_portal": "Zendesk Plan", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2012-10-19T01:01:32Z", "updated_at": "2014-11-08T10:47:55Z", "removable": true, "custom_field_options": [ { "id": 21332256, "name": "Test", "raw_name": "Test", "value": "zdplan_test" } ] } } ');
      return res;
    }
  }

  public class MockUsersResponse implements HttpCalloutMock {
    private String page;
    public MockUsersResponse(String page) {this.page = page;}

    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setStatusCode(200);
      res.setStatus('OK');
      if (page == null) {
          res.setBody('{ "user_fields": [ { "url": "https://support.zendesk.com/api/v2/user_fields/23164018.json", "id": 23164018, "type": "text", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": "https://support.zendesk.com/api/v2/user_fields.json?page=2", "previous_page": null, "count": 1 }');
      } else {
          res.setBody('{ "user_fields": [ { "url": "https://support.zendesk.com/api/v2/user_fields/23164018.json", "id": 23164018, "type": "text", "title": "Test", "raw_title": "Test", "description": "Test", "raw_description": "Test", "position": 9999, "active": false, "required": false, "collapsed_for_agents": false, "regexp_for_validation": null, "title_in_portal": "Test", "raw_title_in_portal": "Test", "visible_in_portal": false, "editable_in_portal": false, "required_in_portal": false, "tag": null, "created_at": "2013-08-28T05:57:11Z", "updated_at": "2013-08-29T07:11:23Z", "removable": true } ], "next_page": null, "previous_page": null, "count": 1 }');
      }
      return res;
    }
  }

  static testMethod void testGetUserField() {
    Test.setMock(HttpCalloutMock.class, new MockUserResponse());

    ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);

    Test.startTest();
    ZendeskUserFields zfields = new ZendeskUserFields(zapi);
    ZendeskAPISchema.ZUserField testObj = zfields.getUserField('Test');
    Test.stopTest();

    System.assertNotEquals(null, testObj);
  }

  static testMethod void testGetUserFieldsNoPage() {
    Test.setMock(HttpCalloutMock.class, new MockUsersResponse(null));

    ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);

    Test.startTest();
    ZendeskUserFields zfields = new ZendeskUserFields(zapi);
    ZendeskAPISchema.ZUserField testObj = zfields.getUserField('Test');
    Test.stopTest();

    System.assertNotEquals(null, testObj);
  }

  static testMethod void testGetUserFieldsWithPage() {
    Test.setMock(HttpCalloutMock.class, new MockUsersResponse('1'));

    ZendeskAPI zapi = new ZendeskAPI('subdomain', 'username', 'password', ZendeskAPI.AuthType.Password);

    Test.startTest();
    ZendeskUserFields zfields = new ZendeskUserFields(zapi);
    ZendeskAPISchema.ZUserField testObj = zfields.getUserField('Test');
    Test.stopTest();

    System.assertNotEquals(null, testObj);
  }

}
