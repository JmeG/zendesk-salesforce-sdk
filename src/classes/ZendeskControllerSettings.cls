global class ZendeskControllerSettings {

    global static String getNamedCredential() {
        return 'Zendesk_API_Credentials';
    }

    global static ZendeskConnection getConnection() {
        return ZendeskConnection.createWithNamedCredential(getNamedCredential());
    }
}
