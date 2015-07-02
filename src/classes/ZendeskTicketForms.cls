// This class provides common functionality to call the Zendesk API to interact with Ticket Form records
public with sharing class ZendeskTicketForms {

	private final ZendeskAPI zapi;
	private Map<String, ZendeskAPISchema.ZTicketForm> resultsMap;

	private class ResultsWrapper {
		public ZendeskAPISchema.ZTicketForm[] ticket_forms {get;set;}

		// "https://support.zendesk.com/api/v2/ticket_forms.json?page=2"
		public String next_page {get;set;}
		public Integer nextPageNumber {
			public get { return (String.isEmpty(next_page) ? null : Integer.valueOf(next_page.substringAfterLast('page=').substringBefore('&'))); }
			private set;
		}
	}

	public ZendeskTicketForms(ZendeskAPI zapi) {
		this.zapi = zapi;
		resultsMap = new Map<String, ZendeskAPISchema.ZTicketForm>();
	}

	public ZendeskAPISchema.ZTicketForm getTicketForm(String name) {
		if (resultsMap.isEmpty()) {
			loadAll();
		}

		ZendeskAPISchema.ZTicketForm obj = null;
		if (resultsMap.containsKey(name)) {
			obj = resultsMap.get(name);
		}

		// Testing support
		if (Test.isRunningTest() && obj == null) {
			obj = resultsMap.get('Test');
		}

		return obj;
	}

	private void loadAll() {
		ResultsWrapper wrapper = getTicketForms();
		System.debug('**wrapper=' + wrapper);
		if (wrapper != null && wrapper.ticket_forms != null) {
			for (ZendeskAPISchema.ZTicketForm obj : wrapper.ticket_forms) {
				resultsMap.put(obj.raw_name, obj);
			}

			while (!String.isEmpty(wrapper.next_page)) {
				System.debug('**wrapper.next_page=' + wrapper.next_page);
				wrapper = getTicketForms(wrapper.nextPageNumber);
				for (ZendeskAPISchema.ZTicketForm obj : wrapper.ticket_forms) {
					resultsMap.put(obj.raw_name, obj);
				}
			}
		}
	}

	private ResultsWrapper getTicketForms() {
		return getTicketForms(null);
	}

	private ResultsWrapper getTicketForms(Integer page) {
		Http h = new Http();
		HttpRequest queryReq = zapi.setupRequest('GET', '/api/v2/ticket_forms.json' + (page==null ? '' : '?page=' + String.valueOf(page)));
		HttpResponse res = new HttpResponse();
		if (!Test.isRunningTest()) {
			res = h.send(queryReq);
		} else {
			// fake response
			res = new HttpResponse();
			res.setStatusCode(200);
			res.setStatus('OK');
			if (page == null) {
				res.setBody('{ "ticket_forms": [ { "url": "https://support.zendesk.com/api/v2/ticket_forms/466.json", "id": 466, "name": "Test", "raw_name": "Test", "display_name": "Test", "raw_display_name": "Test", "end_user_visible": true, "position": 0, "active": true, "default": true, "created_at": "2013-04-23T01:24:04Z", "updated_at": "2013-08-07T21:29:47Z" } ], "next_page": "https://support.zendesk.com/api/v2/ticket_forms.json?page=2", "previous_page": null, "count": 1 }');
			} else {
				res.setBody('{ "ticket_forms": [ { "url": "https://support.zendesk.com/api/v2/ticket_forms/466.json", "id": 466, "name": "Test", "raw_name": "Test", "display_name": "Test", "raw_display_name": "Test", "end_user_visible": true, "position": 0, "active": true, "default": true, "created_at": "2013-04-23T01:24:04Z", "updated_at": "2013-08-07T21:29:47Z" } ], "next_page": null, "previous_page": null, "count": 1 }');
			}
		}
		System.debug('getTicketForms res: ' + res);
		String resBody = res.getBody();
		System.debug('resBody: ' + resBody);

		ResultsWrapper wrapper = null;
		if (res.getStatusCode() == 200) {
			wrapper = (ResultsWrapper)JSON.deserialize(resBody, ResultsWrapper.class);
		}

		return wrapper;
	}
}