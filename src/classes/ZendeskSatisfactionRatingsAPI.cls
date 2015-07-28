// This class provides functionality to call the Zendesk SatisfactionRatings API
public class ZendeskSatisfactionRatingsAPI extends ZendeskResourceBase {

    public class SatisfactionRatingWrapper extends ZendeskSideLoadingBase {
        public ZSatisfactionRating satisfaction_rating {get;set;}
		public SatisfactionRatingWrapper(ZSatisfactionRating satisfaction_rating) { this.satisfaction_rating = satisfaction_rating; }
    }

    public class SatisfactionRatingsWrapper extends ZendeskPagingBase {
        public List<ZSatisfactionRating> satisfaction_ratings {get;set;}
		public SatisfactionRatingsWrapper(List<ZSatisfactionRating> satisfaction_ratings) { this.satisfaction_ratings = satisfaction_ratings; }
    }

    public ZendeskSatisfactionRatingsAPI(ZendeskAPI zapi) {
        super(zapi);
    }

    // GET /api/v2/satisfaction_ratings/{id}.json
    public SatisfactionRatingWrapper getSatisfactionRating(Long satRatingId) {
        if (satRatingId == null) { throw new ZendeskException('satRatingId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/satisfaction_ratings/'+satRatingId+'.json');
        return (SatisfactionRatingWrapper)JSON.deserialize(zapi.sendRequest(req), SatisfactionRatingWrapper.class);
    }

    // GET /api/v2/satisfaction_ratings.json
    public SatisfactionRatingsWrapper getSatisfactionRatings() {
        return getSatisfactionRatings(null);
    }
    public SatisfactionRatingsWrapper getSatisfactionRatings(Map<String, Object> queryParams) {
        HttpRequest req = zapi.createRequest('GET', '/satisfaction_ratings.json', queryParams);
        return (SatisfactionRatingsWrapper)JSON.deserialize(zapi.sendRequest(req), SatisfactionRatingsWrapper.class);
    }

	// POST /api/v2/tickets/{ticket_id}/satisfaction_rating.json
	public void createSatisfactionRating(ZSatisfactionRating satRating, Long ticketId) {
		if (satRating == null) { throw new ZendeskException('satRating parameter must not be null'); }
		if (ticketId == null) { throw new ZendeskException('ticketId parameter must not be null'); }

		HttpRequest req = zapi.createRequest('POST', '/tickets/'+ticketId+'/satisfaction_rating.json');
		req.setBody(JSON.serialize(new SatisfactionRatingWrapper(satRating)));
		zapi.sendRequest(req);
	}
}
