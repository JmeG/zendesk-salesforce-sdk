// Custom exception type used when there is an unsuccessful response from a Zendesk API
global virtual class ZendeskResponseException extends Exception {

    global ZendeskConnection.ZendeskError zendeskError;

    global ZendeskResponseException(String message, ZendeskConnection.ZendeskError zendeskError) {
        this(message);
        this.zendeskError = zendeskError;
    }
}
