// This class provides test coverage for the ZendeskJobStatusesAPI class by testing each flavor of API response from getting Job Status or Job Statuses
@isTest
private class ZendeskJobStatusesAPITests {

  private Static String STATUS_STR_1  = '{\"job_status\": {' +
                                          '\"id\":     \"8b726e606741012ffc2d782bcb7848fe\",' +
                                          '\"url\":    \"https://company.zendesk.com/api/v2/job_statuses/8b726e606741012ffc2d782bcb7848fe.json\",' +
                                          '\"total\":  2,' +
                                          '\"progress\": 2,' +
                                          '\"status\":   \"completed\",' +
                                          '\"message\":  \"Completed at Fri Apr 13 02:51:53 +0000 2012\",' +
                                          '\"results\": [{' +
                                              '\"title\":   \"I accidentally the whole bottle\",' +
                                              '\"action\":  \"update\",' +
                                              '\"errors\":  \"\",' +
                                              '\"id\":    380,' +
                                              '\"success\": true,' +
                                              '\"status\":  \"Updated\"' +
                                           '},' +
                                           '{' +
                                              '\"title\":   \"Printer on fire\",' +
                                              '\"action\":  \"update\",' +
                                              '\"errors\":  \"blah error\",' +
                                              '\"id\":    90,' +
                                              '\"success\": true,' +
                                              '\"status\":  \"Updated\"' +
                                             '}]'+
                                           '}'+
                                          '}';

  private Static String STATUS_STR_2  = '{\"job_statuses\": [{' +
                                          '\"id\":\"123\",' +
                                          '\"url\":\"https://z3nvandelay16.zendesk.com/api/v2/job_statuses/123.json\",' +
                                          '\"total\":2,' +
                                          '\"progress\":2,' +
                                          '\"status\":\"completed\",' +
                                          '\"message\":\"Completed at 2015-10-30 21:31:59 +0000\",' +
                                          '\"results\":[]' +
                                         '},' +
                                         '{' +
                                          '\"id\":\"456\",' +
                                          '\"url\":\"https://z3nvandelay16.zendesk.com/api/v2/job_statuses/456.json\",' +
                                          '\"total\":1,' +
                                          '\"progress\":1,' +
                                          '\"status\":\"completed\",' +
                                          '\"message\":\"Completed at 2015-10-30 21:33:20 +0000\",' +
                                          '\"results\": [' +
                                              '{' +
                                                '\"index\":       0,' +
                                                '\"error\":       \"OrganizationUpdateFailed\",' +
                                                '\"external_id\": \"2324299999\",' +
                                                '\"details\":     \"Custom field values base LG Owner is invalid (not a valid drop-down option)\"' +
                                              '},' +
                                              '{' +
                                                '\"index\":       1,' +
                                                '\"error\":       \"OrganizationUpdateFailed\",' +
                                                '\"external_id\": \"ref95884\",' +
                                                '\"details\":     \"Custom field values base LG Owner is invalid (not a valid drop-down option)\"' +
                                              '},' +
                                              '{' +
                                                '\"index\":       2,' +
                                                '\"error\":       \"OrganizationNotFound\",' +
                                                '\"external_id\": \"653513739\"' +
                                              '},' +
                                              '{' +
                                                '\"index\":       3,' +
                                                '\"error\":       \"OrganizationUpdateFailed\",' +
                                                '\"external_id\": \"2131237373\",' +
                                                '\"details\":     \"Custom field values base CAM Owner is invalid (not a valid drop-down option)\"' +
                                              '}]}],' +
                                       '\"next_page\":null,' +
                                       '\"previous_page\":null,' +
                                       '\"count\":2' +
                                    '}';

  private Static String STATUS_STR_3 = '{\"job_status\": { ' +
                                          '\"id\": \"31a2e47012e20\",' +
                                          '\"url\": \"https://test.zendesk.com/api/v2/job_statuses/31a2e4701.json\",' +
                                          '\"total\": 2,' +
                                          '\"progress\": 2,' +
                                          '\"status\": \"completed\",' +
                                          '\"message\": \"Completed\",' +
                                          '\"results\": [{' +
                                            '\"status\": \"Failed Creating User\",'+
                                            '\"errors\": \"Name:  is too short\"}]}}';

    public class MockStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(STATUS_STR_3);
            return res;
        }
    }

    public class MockStatusesResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody(STATUS_STR_2);

            return res;
        }
    }

    @isTest static void testGetStatus() {
        Test.setMock(HttpCalloutMock.class, new MockStatusResponse());

        Test.startTest();
        ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(ZendeskConnection.createWithPassword('s','u','p'));
        ZendeskTypes.ZJobStatus jstatus = zjobs_api.getJobStatus('abc123');
        Test.stopTest();

        System.assertNotEquals(null, jstatus);
        System.assertEquals('31a2e47012e20', jstatus.id);
        System.assertEquals('https://test.zendesk.com/api/v2/job_statuses/31a2e4701.json', jstatus.url);
        System.assertEquals(2, jstatus.total);
        System.assertEquals(2, jstatus.progress);
        System.assertEquals('completed', jstatus.status);
        System.assertEquals('Completed', jstatus.message);
        System.assertEquals('Failed Creating User', jstatus.results[0].status);
        System.assertEquals('Name:  is too short', jstatus.results[0].errors);
    }

    @isTest static void testGetStatuses() {
        Test.setMock(HttpCalloutMock.class, new MockStatusesResponse());

        Test.startTest();
        ZendeskJobStatusesAPI zjobs_api = new ZendeskJobStatusesAPI(ZendeskConnection.createWithPassword('s','u','p'));
        Map<String, Object> jobStatusMap = zjobs_api.getJobStatuses(new Set<String> {'abc123', 'abc345'});
        Test.stopTest();

        System.assertNotEquals(null, jobStatusMap);
        System.assertEquals(4, jobStatusMap.size());
    }

    @isTest static void testDeserialize() {
        String jsonStr = STATUS_STR_1;

        // ZendeskTypes.ZJobStatus jstatus = (ZendeskTypes.ZJobStatus)JSON.deserialize(jsonStr, ZendeskTypes.ZJobStatus.class);
        ZendeskJobStatusWrapper jstatus = ZendeskJobStatusWrapper.parse(jsonStr);
        System.assertNotEquals(null, jstatus);
        System.assertEquals('8b726e606741012ffc2d782bcb7848fe', jstatus.job_status.id);
        System.assertEquals('https://company.zendesk.com/api/v2/job_statuses/8b726e606741012ffc2d782bcb7848fe.json', jstatus.job_status.url);
        System.assertEquals(2, jstatus.job_status.total);
        System.assertEquals(2, jstatus.job_status.progress);
        System.assertEquals('completed', jstatus.job_status.status);
        System.assertEquals('Completed at Fri Apr 13 02:51:53 +0000 2012', jstatus.job_status.message);
        System.assertEquals(2, jstatus.job_status.results.size());

        if (jstatus.job_status.results[0].title == 'I accidentally the whole bottle') {
            System.assertEquals('I accidentally the whole bottle', jstatus.job_status.results[0].title);
            System.assertEquals('update', jstatus.job_status.results[0].action);
            System.assertEquals('', jstatus.job_status.results[0].errors);
            System.assertEquals(380, jstatus.job_status.results[0].id);
            System.assert(jstatus.job_status.results[0].success);
            System.assertEquals('Updated', jstatus.job_status.results[0].status);
        }
        else {
            System.assertEquals('Printer on fire', jstatus.job_status.results[1].title);
            System.assertEquals('update', jstatus.job_status.results[1].action);
            System.assertEquals('blah error', jstatus.job_status.results[1].errors);
            System.assertEquals(90, jstatus.job_status.results[1].id);
            System.assert(jstatus.job_status.results[1].success);
            System.assertEquals('Updated', jstatus.job_status.results[1].status);
        }
    }

    @isTest static void testDeserializeMultipleJobs() {
        String jsonStr = STATUS_STR_2;

        ZendeskJobStatusWrapper jstatus = ZendeskJobStatusWrapper.parse(jsonStr);
        ZendeskTypes.ZJobStatus[] jstatusList = new List<ZendeskTypes.ZJobStatus>();
        jstatusList.addAll(jstatus.job_statuses);
        //System.debug('$$$$ JSTATUS ' +  jstatusList);

        System.assertEquals(2, jstatusList.size());
        System.assertEquals('123', jstatusList[0].id);
        System.assertEquals('https://z3nvandelay16.zendesk.com/api/v2/job_statuses/123.json', jstatusList[0].url);
        System.assertEquals(2, jstatusList[0].total);
        System.assertEquals(2, jstatusList[0].progress);
        System.assertEquals('completed', jstatusList[0].status);
        System.assertEquals('Completed at 2015-10-30 21:31:59 +0000', jstatusList[0].message);
        System.assertEquals(0, jstatusList[0].results.size());

        System.assertEquals('456', jstatusList[1].id);
        System.assertEquals('https://z3nvandelay16.zendesk.com/api/v2/job_statuses/456.json', jstatusList[1].url);
        System.assertEquals(1, jstatusList[1].total);
        System.assertEquals(1, jstatusList[1].progress);
        System.assertEquals('completed', jstatusList[1].status);
        System.assertEquals('Completed at 2015-10-30 21:33:20 +0000', jstatusList[1].message);
        System.assertEquals(4, jstatusList[1].results.size());

        System.assertEquals(0, jstatusList[1].results[0].index);
        System.assertEquals('OrganizationUpdateFailed', jstatusList[1].results[0].error);
        System.assertEquals('2324299999', jstatusList[1].results[0].external_id);
        System.assertEquals('Custom field values base LG Owner is invalid (not a valid drop-down option)', jstatusList[1].results[0].details[0]);

        System.assertEquals(1, jstatusList[1].results[1].index);
        System.assertEquals('OrganizationUpdateFailed', jstatusList[1].results[1].error);
        System.assertEquals('ref95884', jstatusList[1].results[1].external_id);
        System.assertEquals('Custom field values base LG Owner is invalid (not a valid drop-down option)', jstatusList[1].results[1].details[0]);

        System.assertEquals(2, jstatusList[1].results[2].index);
        System.assertEquals('OrganizationNotFound', jstatusList[1].results[2].error);
        System.assertEquals('653513739', jstatusList[1].results[2].external_id);

        System.assertEquals(3, jstatusList[1].results[3].index);
        System.assertEquals('OrganizationUpdateFailed', jstatusList[1].results[3].error);
        System.assertEquals('2131237373', jstatusList[1].results[3].external_id);
        System.assertEquals('Custom field values base CAM Owner is invalid (not a valid drop-down option)', jstatusList[1].results[3].details[0]);
    }

}
