// This class provides functionality to call the Zendesk SatisfactionRatings API
global class ZendeskSatisfactionRatingsAPI extends ZendeskResourceBase {

    global class SatisfactionRatingWrapper extends ZendeskSideLoadingBase {
        global ZSatisfactionRating satisfaction_rating { get; set; }
        global SatisfactionRatingWrapper(ZSatisfactionRating satisfaction_rating) { this.satisfaction_rating = satisfaction_rating; }
    }

    global class SatisfactionRatingsWrapper extends ZendeskPagingBase {
        global List<ZSatisfactionRating> satisfaction_ratings { get; set; }
        global SatisfactionRatingsWrapper(List<ZSatisfactionRating> satisfaction_ratings) { this.satisfaction_ratings = satisfaction_ratings; }
    }

    global ZendeskSatisfactionRatingsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    // GET /api/v2/satisfaction_ratings/{id}.json
    global SatisfactionRatingWrapper getSatisfactionRating(Long satRatingId) {
        if (satRatingId == null) { throw new ZendeskException('satRatingId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/satisfaction_ratings/'+satRatingId+'.json');
        return (SatisfactionRatingWrapper)JSON.deserialize(zconn.sendRequest(req), SatisfactionRatingWrapper.class);
    }

    /*
    Filters:
     score=received | received_with_comment | received_without_comment | good | good_with_comment | good_without_comment | bad | bad_with_comment | bad_without_comment
     start_time: Time of the oldest satisfaction rating to retrieve in Unix epoch time
     end_time: Time of the most recent satisfaction rating to retrieve in Unix epoch time
    */

    // GET /api/v2/satisfaction_ratings.json
    global SatisfactionRatingsWrapper getSatisfactionRatings() {
        return getSatisfactionRatings(null);
    }
    global SatisfactionRatingsWrapper getSatisfactionRatings(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/satisfaction_ratings.json', queryParams);
        return (SatisfactionRatingsWrapper)JSON.deserialize(zconn.sendRequest(req), SatisfactionRatingsWrapper.class);
    }

    // POST /api/v2/tickets/{ticket_id}/satisfaction_rating.json
    global void createSatisfactionRating(ZSatisfactionRating satRating, Long ticketId) {
        if (satRating == null) { throw new ZendeskException('satRating parameter cannot be null'); }
        if (ticketId == null) { throw new ZendeskException('ticketId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/tickets/'+ticketId+'/satisfaction_rating.json');
        req.setBody(JSON.serialize(new SatisfactionRatingWrapper(satRating)));
        zconn.sendRequest(req);
    }
}
