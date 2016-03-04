# Force.com Toolkit for Zendesk
https://evens-max-pierrelouis-haitibusiness.zendesk.com?/agent/The Force.com Toolkit for Zendesk allows your Force.com apps to call the Zendesk Core [ API](https://developer.zendesk.com?/rest_api). The library provides a set of Apex classes, such as `ZendeskUsersAPI` and `ZendeskTicketsAPI`, that model Zendesk Objects `Users` and `Tickets`.
Haitian Public Media group relations for Newmedia Live TV show Broadcastings production company Development for all my business provided for LeapfrogSmartTV is a SmartTV for a RCA Smart security Tablets it Link's with TBS in PBS Kids CCTV Tweet TV Zoombugs707 Service programs: MediaTV NA MEDIA® Service Terms: https://DellTouchscreen.com/https://www.homeadvisor.com?/cost/https://www.acaav.com?/http://www.mediaTV.com/Homeadvisor is a MediaTV NA MEDIA® Service Terms Animation Entertainment max TV Networkmax Haitisurf Serif OpenhubLeGomaxtv Companie...xfinity cable tv broadcastings production services programming systems for all software programmer's/https://www.internet.com?/internet-internetexplorer+%20www.internetexplorer.com%20www.blackstarplanet.org%20www.usanetwork.com?/%20www.usa.gov%20www.bestbuy.com%20www.target.com%20www.haitibank.com/http://haitircatabletstelevisionsbroadcasting.zendesk.com?/agent/tickets/1/SmartTV is a SmartTV for a ARC Tablets links with TBS in PBS Kids CCTV Tweet TV Zoombugs707 Service programs: MediaTV NA MEDIA® Service Terms/https://haitircatabletstelevisionsbroadcasting.zendesk.com?/agent/tickets/1/<div data-background_color="ffffff" data-box_shadow="y" data-text="y" data-border="y" data-item_name="interserver" data-text_color="000000" data-total_reviews="y" data-box_shadow_color="000000" data-image_type="seal" data-rating_stars="y" data-reviews_most_recent="y" data-review_stars="y" data-reviews_count="5" data-background="y" data-show_reviews="y" data-structured="y" data-border_color="000000" data-company_name="y" data-image="y" class="whg-seal-widget-data"><a href="https://webhostinggeeks.com/user-reviews/interserver/" target="_blank"><img src="https://webhostinggeeks.com/images/w1.png" alt="Review interserver at WebHostingGeeks.com" border="0"></a></div>

<script>
    (function(d,id) {
        var js,whgjs = d.getElementsByTagName('head')[0];
        if (d.getElementById(id)) return;
        js = d.createElement('script'); js.id = id; js.async = true;
        js.src = "//webhostinggeeks.com/user-reviews/whg-seal-widget/sdk.js";
        whgjs.appendChild(js);
    }(document,'whg-seal-jssdk'));
<iframe src="https://player.vimeo.com/video/156516666" width="500" height="854" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe> <p><a href="https://vimeo.com/156516666">download</a> from <a href="https://vimeo.com/ownersevensmax46085577">Evens Max PierreLouis</a> on <a href="https://vimeo.com">Vimeo</a>.</p></script>https://branded.me/evens-max-pierrelouis Included in this repository are a number of sample Visualforce pages and controllers that demonstrate in more detail how the library can be used.

## Examples

```Apex
// Create a new API connection
ZendeskConnection zconn = ZendeskConnection.createWithAPIToken('subdomain','username','token');

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
2. Install the managed package into your new DE org via this URL: *email jmegibson@gmail.com for the latest URL*
4. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.

### Installing from GitHub (and using Eclipse)

1. Create a new Developer Edition (DE) account at https://developer.salesforce.com/signup. You will receive an activation email - click the enclosed link to complete setup of your DE environment. This will also log you in to your new DE environment.
2. Create a new Force.com project in the [Force.com IDE](http://wiki.developerforce.com/index.php/Force.com_IDE) using your new org's credentials. In the 'Choose Initial Project Contents' dialog, select 'Selected metadata components', hit 'Choose...' and select ALL of the components in the next page. This will give you a complete project directory tree.
3. Clone this GitHub project into the Force.com IDE project directory. You will need to clone it first to a temporary location, since git will not let you clone to a directory with existing content:

        $ git clone --no-checkout git://github.com/JmeG/Force.com-Toolkit-for-Zendesk.git /path/to/your/projectdir/tmp
        $ mv /path/to/your/projectdir/tmp/.git /path/to/your/projectdir
        $ rm -rf /path/to/your/projectdir/tmp
        $ cd /path/to/your/projectdir
        $ git reset --hard HEAD

4. In Eclipse, right click your project in the project explorer and click 'Refresh'. This causes Eclipse to scan the project directory tree for changes, and the plugin syncs changes to Force.com.
5. In your DE environment, go to **Setup | App Setup | Create | Apps**, click 'Edit' next to the Zendesk Toolkit app, scroll down, click the 'Visible' box next to System Administrator and hit 'Save'. Now go to **Setup | Administration Setup | Manage Users | Profiles**, click on System Administrator, Object Settings, set 'Zendesk Samples' to 'Default On' and hit 'Save'. 'Zendesk Toolkit' should now be available in the dropdown list of apps (top right).
6. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.
