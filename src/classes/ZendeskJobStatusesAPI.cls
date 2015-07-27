// This class provides functionality to call the Zendesk Job Statuses API
public class ZendeskJobStatusesAPI extends ZendeskResourceBase {

	private class JobStatusWrapper {
		public ZJobStatus job_status {get;set;}
	}
	
	private class JobStatusesWrapper {
		public List<ZJobStatus> job_statuses {get;set;}
	}

	public ZendeskJobStatusesAPI(ZendeskAPI zapi) {
		super(zapi);
	}

	public ZJobStatus getJobStatus(String jobId) {
		if (jobId == null) { throw new ZendeskException('jobId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/job_statuses/'+jobId+'.json');
		JobStatusWrapper wrapper = (JobStatusWrapper)JSON.deserialize(zapi.sendRequest(req), JobStatusWrapper.class);
		return wrapper.job_status;
	}

	public List<ZJobStatus> getJobStatuses(Set<String> jobIds) {
		if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('GET', '/job_statuses/show_many.json', new Map<String, Object>{'ids'=>toCSV(jobIds)});
		JobStatusesWrapper wrapper = (JobStatusesWrapper)JSON.deserialize(zapi.sendRequest(req), JobStatusesWrapper.class);
		return wrapper.job_statuses;
	}
}
