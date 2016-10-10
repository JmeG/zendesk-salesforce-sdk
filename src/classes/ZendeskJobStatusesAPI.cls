// This class provides functionality to call the Zendesk Job Statuses API
global class ZendeskJobStatusesAPI extends ZendeskResourceBase {

    global ZendeskJobStatusesAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    global ZendeskTypes.ZJobStatus getJobStatus(String jobId) {
        if (jobId == null) { throw new ZendeskException('jobId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/job_statuses/'+jobId+'.json');

        ZendeskJobStatusWrapper jsw = ZendeskJobStatusWrapper.parse(zconn.sendRequest(req));
        return jsw.job_status;
        //return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }

    global Map<String, Object> getJobStatuses(Set<String> jobIds) {
        if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter cannot be null or empty'); }

        HttpRequest req = zconn.createRequest('GET', '/job_statuses/show_many.json', new Map<String, Object>{'ids'=>toCSV(jobIds)});
        return (Map<String, Object>)JSON.deserializeUntyped(zconn.sendRequest(req));
    }
}
