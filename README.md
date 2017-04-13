# Zendesk SDK for Salesforce

The Zendesk SDK for Salesforce allows your Force.com apps to call the Zendesk Core [ API](https://developer.zendesk.com/rest_api). The library provides a set of Apex classes, such as `ZendeskUsersAPI` and `ZendeskTicketsAPI`, that model Zendesk Objects `Users` and `Tickets`.

View the Zendesk API documentation here https://developer.zendesk.com/rest_api/docs/core/introduction

Included in this repository are a number of sample Visualforce pages and controllers that demonstrate in more detail how the library can be used.

## Examples

```Apex
// Create a new API connection
ZendeskConnection zconn = ZendeskConnection.createWithAPIToken('subdomain','username','token');
or 
ZendeskConnection zconn = ZendeskConnection.createWithNamedCredential('named_credential');

// Get recent Tickets
ZendeskTicketsAPI zapi = new ZendeskTicketsAPI(zconn);
ZendeskTicketsAPI.TicketsWrapper result = zapi.getTickets();
for (ZendeskTypes.ZTicket zt : result.tickets) {
    System.debug(zt);
}

// Update a Ticket
ZendeskTicketsAPI zapi = new ZendeskTicketsAPI(zconn);
ZendeskTypes.ZTicket zt = new ZendeskTypes.ZTicket();
zt.priority = ZendeskTypes.TicketPriority.urgent;
zapi.updateTicket(12345, zt);

// Get Users of an Organization
ZendeskUsersAPI zapi = new ZendeskUsersAPI(zconn);
ZendeskUsersAPI.UsersWrapper result = zapi.getUsersByOrganization(1122334455);
for (ZendeskTypes.ZUser zu : result.users) {
    System.debug(zu);
}

// Search Organizations with paging options
ZendeskOrganizationsAPI orgs_api = new ZendeskOrganizationsAPI(zconn);
Map<String, Object> params = new Map<String, Object>{'per_page'=>20, 'page'=>2};
ZendeskOrganizationsAPI.OrganizationsWrapper orgsWrapper = orgs_api.autocompleteSearch('searchText', params);
```

## Implemented Resources

- Attachments
- Autocomplete
- Group Memberships
- Groups
- Job Statuses
- Organization Fields
- Organization Memberships
- Organizations
- Satisfaction Ratings
- Search
- Sessions
- Tags
- Ticket Comments
- Ticket Fields
- Ticket Forms
- Ticket Metrics
- Tickets
- User Fields
- Users

## Installation

There are two mechanisms for installing the toolkit: as a managed package or from GitHub. Choose the managed package if you only want the Apex API library without sample code. If you are considering modifying or extending the toolkit itself or want to install the sample Visualforce pages, then installing from GitHub is a little more work, but will enable you to easily contribute code back to the project.

### Installing the Managed Package

1. Create a new Developer Edition (DE) account at https://developer.salesforce.com/signup. You will receive an activation email - click the enclosed link to complete setup of your DE environment. This will also log you in to your new DE environment.
2. Install the managed package into your new DE org via this URL: (email me for the latest URL. My email is listed in my GitHub profile)
4. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.

### Installing from GitHub (and using MavensMate)
1. Clone project to your local filesystem
`$ git clone https://github.com/JmeG/zendesk-salesforce-sdk.git`
2. Drag directory into Sublime Text
3. Right click the project root in the Sublime Text sidebar
4. Select `MavensMate > Create MavensMate Project.`
5. You will then be prompted for Salesforce.com credentials.

### Installing from GitHub (and using Eclipse)

1. Create a new Developer Edition (DE) account at https://developer.salesforce.com/signup. You will receive an activation email - click the enclosed link to complete setup of your DE environment. This will also log you in to your new DE environment.
2. Create a new Force.com project in the [Force.com IDE](http://wiki.developerforce.com/index.php/Force.com_IDE) using your new org's credentials. In the 'Choose Initial Project Contents' dialog, select 'Selected metadata components', hit 'Choose...' and select ALL of the components in the next page. This will give you a complete project directory tree.
3. Clone this GitHub project into the Force.com IDE project directory. You will need to clone it first to a temporary location, since git will not let you clone to a directory with existing content:

        $ git clone --no-checkout git://github.com/JmeG/zendesk-salesforce-sdk.git /path/to/your/projectdir/tmp
        $ mv /path/to/your/projectdir/tmp/.git /path/to/your/projectdir
        $ rm -rf /path/to/your/projectdir/tmp
        $ cd /path/to/your/projectdir
        $ git reset --hard HEAD

4. In Eclipse, right click your project in the project explorer and click 'Refresh'. This causes Eclipse to scan the project directory tree for changes, and the plugin syncs changes to Force.com.
5. In your DE environment, go to **Setup | App Setup | Create | Apps**, click 'Edit' next to the Zendesk Toolkit app, scroll down, click the 'Visible' box next to System Administrator and hit 'Save'. Now go to **Setup | Administration Setup | Manage Users | Profiles**, click on System Administrator, Object Settings, set 'Zendesk Samples' to 'Default On' and hit 'Save'. 'Zendesk Toolkit' should now be available in the dropdown list of apps (top right).
6. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.

### Installing from GitHub (direct deploy)

https://githubsfdeploy.herokuapp.com/app/githubdeploy/JmeG/zendesk-salesforce-sdk
