// This class provides functionality to call the Zendesk Job Statuses API
public class ZendeskJobStatusesAPI extends ZendeskResourceBase {

	private class JobStatusWrapper {
		public ZJobStatus job_status {get;set;}
	}
	
	private class JobStatusesWrapper {
		public List<ZJobStatus> job_statuses {get;set;}
	}

	public ZendeskJobStatusesAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	public ZJobStatus getJobStatus(String jobId) {
		if (jobId == null) { throw new ZendeskException('jobId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/job_statuses/'+jobId+'.json');
		JobStatusWrapper wrapper = (JobStatusWrapper)JSON.deserialize(zconn.sendRequest(req), JobStatusWrapper.class);
		return wrapper.job_status;
	}

	public List<ZJobStatus> getJobStatuses(Set<String> jobIds) {
		if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('GET', '/job_statuses/show_many.json', new Map<String, Object>{'ids'=>toCSV(jobIds)});
		JobStatusesWrapper wrapper = (JobStatusesWrapper)JSON.deserialize(zconn.sendRequest(req), JobStatusesWrapper.class);
		return wrapper.job_statuses;
	}
}
