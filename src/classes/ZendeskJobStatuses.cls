// This class provides functionality to call the Zendesk Job Statuses API
// Currently supports the following API endpoints:
// GET /api/v2/job_statuses/{id}.json
// GET /api/v2/job_statuses/show_many.json?ids={ids}
public class ZendeskJobStatuses {

	private final ZendeskAPI zapi;

	public class JobStatus {
		public String id {get;set;}
		public String url {get;set;}
		public Integer total {get;set;}
		public Integer progress {get;set;}
		public String status {get;set;}
		public String message {get;set;}
		public List<JobStatusResults> results {get;set;}
	}

	public class JobStatusResults {
		public Integer id {get;set;}
		public String title {get;set;}
		public String action {get;set;}
		public String errors {get;set;}
		public Boolean success {get;set;}
		public String status {get;set;}
	}

	private class JobStatusesWrapper {
		public List<JobStatus> job_statuses {get;set;}
	}

	private class JobStatusWrapper {
		public JobStatus job_status {get;set;}
	}

	public ZendeskJobStatuses(ZendeskAPI zapi) {
		this.zapi = zapi;
	}

	public JobStatus getJobStatus(String jobId) {
		if (jobId == null) { throw new ZendeskException('jobId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('GET', '/job_statuses/' + jobId + '.json');
		String resBody = zapi.sendRequest(req);

		JobStatusWrapper wrapper = (JobStatusWrapper)JSON.deserialize(resBody, JobStatusWrapper.class);
		return wrapper.job_status;
	}

	public List<JobStatus> getJobStatuses(Set<String> jobIds) {
		if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('GET', '/job_statuses/show_many.json?ids=' + ZendeskAPI.toCSV(jobIds));
		String resBody = zapi.sendRequest(req);

		JobStatusesWrapper wrapper = (JobStatusesWrapper)JSON.deserialize(resBody, JobStatusesWrapper.class);
		return wrapper.job_statuses;
	}
}
