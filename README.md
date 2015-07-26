# Force.com Toolkit for Zendesk

** This is very much still an early work in progress and hasn't been fully tested yet.

The Force.com Toolkit for Zendesk allows your Force.com apps to manipulate the Zendesk [ API](https://developer.zendesk.com/rest_api). The toolkit provides a set of Apex classes, such as `ZendeskUsersAPI` and `ZendeskTicketsAPI`, that model Zendesk Objects `Users` and `Tickets`.

## Installation

There are two mechanisms for installing the toolkit: as an unmanaged package, or from GitHub. Choose the unmanaged package if you will be using the toolkit to develop your own Zendesk app. If you are considering modifying or extending the toolkit itself, then installing from GitHub is a little more work, but will enable you to easily contribute code back to the project.

### Installing the Unmanaged Package

1. Create a new Developer Edition (DE) account at http://developer.force.com/join. You will receive an activation email - click the enclosed link to complete setup of your DE environment. This will also log you in to your new DE environment.
2. Install the unmanaged package into your new DE org via this URL: https://login.salesforce.com/packaging/installPackage.apexp?p0=XXXXXXXXXXXXXX
4. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.

### Installing from GitHub

1. Create a new Developer Edition (DE) account at http://developer.force.com/join. You will receive an activation email - click the enclosed link to complete setup of your DE environment. This will also log you in to your new DE environment.
2. Create a new Force.com project in the [Force.com IDE](http://wiki.developerforce.com/index.php/Force.com_IDE) using your new org's credentials. In the 'Choose Initial Project Contents' dialog, select 'Selected metadata components', hit 'Choose...' and select ALL of the components in the next page. This will give you a complete project directory tree.
3. Clone this GitHub project into the Force.com IDE project directory. You will need to clone it first to a temporary location, since git will not let you clone to a directory with existing content:

        $ git clone --no-checkout git://github.com/JmeG/Force.com-Toolkit-for-Zendesk.git /path/to/your/projectdir/tmp
        $ mv /path/to/your/projectdir/tmp/.git /path/to/your/projectdir
        $ rm -rf /path/to/your/projectdir/tmp
        $ cd /path/to/your/projectdir
        $ git reset --hard HEAD

4. In Eclipse, right click your project in the project explorer and click 'Refresh'. This causes Eclipse to scan the project directory tree for changes, and the plugin syncs changes to Force.com.
5. In your DE environment, go to **Setup | App Setup | Create | Apps**, click 'Edit' next to the Zendesk Toolkit 1 app, scroll down, click the 'Visible' box next to System Administrator and hit 'Save'. Now go to **Setup | Administration Setup | Manage Users | Profiles**, click on System Administrator, Object Settings, set 'Zendesk Samples' to 'Default On' and hit 'Save'. 'Zendesk Toolkit 1' should now be available in the dropdown list of apps (top right).
6. Go to **Setup | Administration Setup | Security Controls | Remote Site Settings** and add https://yoursubdomain.zendesk.com as a new remote site.
