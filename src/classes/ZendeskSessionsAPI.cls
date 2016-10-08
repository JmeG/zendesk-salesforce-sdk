// This class provides functionality to call the Zendesk Sessions API
global class ZendeskSessionsAPI extends ZendeskResourceBase {

    global class SessionWrapper {
        global ZSession session { get; set; }
        global SessionWrapper(ZSession session) { this.session = session; }
    }

    global class SessionsWrapper extends ZendeskPagingBase {
        global List<ZSession> sessions { get; set; }
        global SessionsWrapper(List<ZSession> sessions) { this.sessions = sessions; }
    }

    global ZendeskSessionsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    // GET /api/v2/users/{user_id}/sessions/{id}.json
    global SessionWrapper getSession(Long userId, Long sessionId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (sessionId == null) { throw new ZendeskException('sessionId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'/sessions/'+sessionId+'.json');
        return (SessionWrapper)JSON.deserialize(zconn.sendRequest(req), SessionWrapper.class);
    }

    // GET /api/v2/users/me/session.json
    global SessionWrapper getMySession() {
        HttpRequest req = zconn.createRequest('GET', '/users/me/session.json');
        return (SessionWrapper)JSON.deserialize(zconn.sendRequest(req), SessionWrapper.class);
    }

    // GET /api/v2/sessions.json
    global SessionsWrapper getSessions() {
        HttpRequest req = zconn.createRequest('GET', '/sessions.json');
        return (SessionsWrapper)JSON.deserialize(zconn.sendRequest(req), SessionsWrapper.class);
    }
    global SessionsWrapper getSessions(Map<String, Object> queryParams) {
        HttpRequest req = zconn.createRequest('GET', '/sessions.json', queryParams);
        return (SessionsWrapper)JSON.deserialize(zconn.sendRequest(req), SessionsWrapper.class);
    }

    // GET /api/v2/users/{user_id}/sessions.json
    global SessionsWrapper getSessions(Long userId) {
        return getSessions(userId, null);
    }
    global SessionsWrapper getSessions(Long userId, Map<String, Object> queryParams) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'/sessions.json', queryParams);
        return (SessionsWrapper)JSON.deserialize(zconn.sendRequest(req), SessionsWrapper.class);
    }

    // DELETE /api/v2/users/me/logout.json
    global void deleteMySession() {
        zconn.sendRequest(zconn.createRequest('DELETE', '/users/me/logout.json'));
    }

    // DELETE /api/v2/users/{user_id}/sessions/{id}.json
    global void deleteSession(Long userId, Long sessionId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (sessionId == null) { throw new ZendeskException('sessionId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/'+userId+'/sessions/'+sessionId+'.json'));
    }

    // DELETE /api/v2/users/{user_id}/sessions.json
    global void deleteSessions(Long userId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/'+userId+'/sessions.json'));
    }
}
