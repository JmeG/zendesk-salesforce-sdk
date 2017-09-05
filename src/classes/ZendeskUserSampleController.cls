public class ZendeskUserSampleController {

    public String nameInput { get; set; }
    public String emailInput { get; set; }

    public ZendeskTypes.ZUser[] users { get; set; }
    public String pageMessage { get; set; }

    public ZendeskUserSampleController() {}

    public PageReference createUser() {
        pageMessage = '';
        users = null;
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(zconn);

            Long newUserId = zusers_api.createUser(nameInput, emailInput);

            pageMessage = 'User created with ID: ' + newUserId;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference findUserByEmail() {
        pageMessage = '';
        users = null;
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(zconn);

            if (String.isEmpty(emailInput)) {
                throw new ZendeskException('You must enter an email address');
            }

            ZendeskTypes.ZUser u = zusers_api.findUserByEmail(emailInput);
            if (u != null) {
                users = new ZendeskTypes.ZUser[] { u };
            }
            else {
                throw new ZendeskException('User not found');
            }
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference findUsersByNameOrEmail() {
        pageMessage = '';
        users = null;
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(zconn);

            String searchStr = '';
            if (String.isEmpty(nameInput) && String.isEmpty(emailInput)) {
                throw new ZendeskException('You must enter a (full or partial) name or email address');
            } else if (!String.isEmpty(emailInput)) {
                searchStr = emailInput;
            } else if (!String.isEmpty(nameInput)) {
                searchStr = nameInput;
            }

            ZendeskUsersAPI.UsersWrapper pagedUsers = zusers_api.findUsersByNameOrEmail(searchStr);
            users = pagedUsers.users;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

    public PageReference getUsers() {
        pageMessage = '';
        users = null;
        try {
            ZendeskConnection zconn = ZendeskControllerSettings.getConnection();
            ZendeskUsersAPI zusers_api = new ZendeskUsersAPI(zconn);

            ZendeskUsersAPI.UsersWrapper pagedUsers = zusers_api.getUsers();
            users = pagedUsers.users;
        }
        catch(Exception e) {
            pageMessage = e.getMessage();
        }
        return null;
    }

}
