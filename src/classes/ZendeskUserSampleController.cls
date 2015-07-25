public class ZendeskUserSampleController {

	public String subdomain {get;set;}
	public String username {get;set;}
	public String pwdOrToken {get;set;}
	public String authType {get;set;}

	public String nameInput {get;set;}
	public String emailInput {get;set;}

	public ZendeskUsersAPI.ZUser[] users {get;set;}
	public String pageMessage {get;set;}

	public ZendeskUserSampleController() {}

	public PageReference createUser() {
		pageMessage = '';
		users = null;
		try {
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskUsersAPI zusers = new ZendeskUsersAPI(zapi);

			Long newUserId = zusers.createUser(nameInput, emailInput);

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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskUsersAPI zusers = new ZendeskUsersAPI(zapi);

			if (String.isEmpty(emailInput)) {
				throw new ZendeskException('You must enter an email address');
			}

			ZendeskUsersAPI.ZUser u = zusers.findUserByEmail(emailInput);
			if (u != null) {
				users = new ZendeskUsersAPI.ZUser[] { u };
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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskUsersAPI zusers = new ZendeskUsersAPI(zapi);

			String searchStr = '';
			if (String.isEmpty(nameInput) && String.isEmpty(emailInput)) {
				throw new ZendeskException('You must enter a (full or partial) name or email address');
			} else if (!String.isEmpty(emailInput)) {
				searchStr = emailInput;
			} else if (!String.isEmpty(nameInput)) {
				searchStr = nameInput;
			}

			ZendeskUsersAPI.UsersWrapper pagedUsers = zusers.findUsersByNameOrEmail(searchStr);
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
			ZendeskAPI zapi = new ZendeskAPI(subdomain, username, pwdOrToken, (authType=='Password' ? ZendeskAPI.AuthType.Password : ZendeskAPI.AuthType.Token));
			ZendeskUsersAPI zusers = new ZendeskUsersAPI(zapi);

			ZendeskUsersAPI.UsersWrapper pagedUsers = zusers.getUsers();
			users = pagedUsers.users;
		}
		catch(Exception e) {
			pageMessage = e.getMessage();
		}
		return null;
	}

}
