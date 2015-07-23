// This class provides functionality to call the Zendesk Job Statuses API
// Currently supports the following API endpoints:
// GET /api/v2/job_statuses/{id}.json
// GET /api/v2/job_statuses/show_many.json?ids={ids}
public class ZendeskJobStatuses {

	private final ZendeskAPI zapi;

	public class JobStatus {
		public String id;
		public String url;
		public Integer total;
		public Integer progress;
		public String status;
		public String message;
		public List<JobStatusResults> results;
	}

	public class JobStatusResults {
		public String title;
		public String action;
		public String errors;
		public Integer id;
		public Boolean success;
		public String status;
	}

	private class JobStatusesWrapper {
		public JobStatus[] job_statuses;
	}

	private class JobStatusWrapper {
		public JobStatus job_status;
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

	public JobStatus[] getJobStatuses(String[] jobIds) {
		if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('GET', '/job_statuses/show_many.json?ids=' + ZendeskAPI.arrayToCSV(jobIds));
		String resBody = zapi.sendRequest(req);

		JobStatusesWrapper wrapper = (JobStatusesWrapper)JSON.deserialize(resBody, JobStatusesWrapper.class);
		return wrapper.job_statuses;
	}
}
