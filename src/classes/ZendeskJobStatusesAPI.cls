// This class provides functionality to call the Zendesk Job Statuses API
global class ZendeskJobStatusesAPI extends ZendeskResourceBase {

	global class JobStatusWrapper {
		global ZJobStatus job_status {get;set;}
	}

	global class JobStatusesWrapper {
		global List<ZJobStatus> job_statuses {get;set;}
	}

	global ZendeskJobStatusesAPI(ZendeskConnection zconn) {
		super(zconn);
	}

	global ZJobStatus getJobStatus(String jobId) {
		if (jobId == null) { throw new ZendeskException('jobId parameter cannot be null'); }

		HttpRequest req = zconn.createRequest('GET', '/job_statuses/'+jobId+'.json');
		JobStatusWrapper wrapper = (JobStatusWrapper)JSON.deserialize(zconn.sendRequest(req), JobStatusWrapper.class);
		return wrapper.job_status;
	}

	global List<ZJobStatus> getJobStatuses(Set<String> jobIds) {
		if (jobIds == null || jobIds.isEmpty()) { throw new ZendeskException('jobIds parameter cannot be null or empty'); }

		HttpRequest req = zconn.createRequest('GET', '/job_statuses/show_many.json', new Map<String, Object>{'ids'=>toCSV(jobIds)});
		JobStatusesWrapper wrapper = (JobStatusesWrapper)JSON.deserialize(zconn.sendRequest(req), JobStatusesWrapper.class);
		return wrapper.job_statuses;
	}
}
