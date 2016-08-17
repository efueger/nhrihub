[![Code Climate](https://codeclimate.com/github/asiapacificforum/nhridocs/badges/gpa.svg)](https://codeclimate.com/github/asiapacificforum/nhridocs)
# NHRIDocs
## Description
NHRIDocs is an internal web application for National Human Rights Institutions ("NHRI") and other complaint handling institutions or human rights monitoring civil society organisations. It comprises a suite of modules that assist in the planning and management of the NHRI's internal processes, accreditation, and performance metrics. It has a range of functionality designed to improve the efficiency and capacity of your organisation, including:
  -  A dynamic human rights indicators monitoring tool aligned to the UN framework of indicators with the ability to download all data and evaluate trends. (ref: http://www.ohchr.org/Documents/Publications/Human_rights_indicators_en.pdf, page 88)
  -  A complaints handling database (set up for complaints relating to human rights or good governance but also customisable)
  -  Strategic plan monitoring – link all of your organisations work to your strategic plan and be able to continuously monitor progress and have a downloadable report available at the click of a button
  -  ICC Accreditation module to help you collate all required documentation for accreditation and reaccreditation (ref: http://nhri.ohchr.org/EN/AboutUs/ICCAccreditation/Pages/default.aspx )
  -  Internal document file management system to store all of your organisation’s files and folders that can be accessible at any time via any computer with an internet connection
  -  Media monitoring tool to track information in the media and collect data that can be used to identify trends and emerging issues

All modules of the application have a range of functionality to assist in the course of your work such as the setting of automatic reminders, logging historical versions of all documents, assigning projects, complaints or other matters to registered users and setting different permission levels to protect the confidentiality and integrity of your documents. Each module can be enabled/disabled to reflect the work undertaken by your organisation.

## Current Status
As of Aug 12, 2016 NHRIdocs is a "feature complete", and is being prepared for its first beta test in a live environment.

## Ruby version
Configured in the .ruby-version file, to support the RVM version manager, look in that file for the currently-configured version

## Internationalization
The basic structure for internationalization has been included.

For languages other than English, locale translation files need to be added in the config/locales directory and subdirectories, as well as the config/locales directories and subdirectories of all the modules in vendor/gems.

Translations may also be required for javascript, these may be found in lib/assets/javascripts/xx.js

The url format for translated versions are (e.g.) your_domain/fr/admin/users.

The default locale is 'en', a different default may be configured within the config/application.rb file, as indicated by the notes within that file.
Page titles automatically default to the text in the i18n translation for the page .heading key, unless a translation for .title is provided.

## Configuration
email
app-specific constants (orgname etc)
timezone
All dates and times are entered and displayed in the timezone configured for the application.
Acceptable file types and maximum file size for uploading internal documents are configurable via the user interface.

## Database creation and initialization
When it is first installed, the access privileges must be "bootstrapped" to permit the first user access. After this, the first user may configure further users through the web user interface.
The first user is configured via a rake command-line utility on the server by running:
```
rake "authengine:bootstrap[firstName,lastName,login,password]"
```
where firstName, lastName, login and password are replaced by the parameters appropriate for the first user.

## Access control
A role-based access control is included. The access is bootstrapped at installation time with a single administrator. This administrator may then define further roles (e.g. "staff", "intern")
Users with the role "admin" have access to the configuration of access permissions for each of the other roles.
When new users are added, they are assigned to the appropriate role in order to limit access to sensitive information.

## Running the test suite
Integration testing uses Rspec with poltergeist/phantomjs as the headless client.
The tests are in spec/features.
Run the main application integration test suite with:
    rspec spec/features
Each of the modules includes its own integration tests. The rails_helper from the main app is included
Each module also includes translation files in its config/locales directory, and for javascript in lib/assets/javascripts/locales
in the module spec/features tests, so the same testing environment applies.
Note that phantomjs 2.0.0 has issues with file uploading (see https://github.com/teampoltergeist/poltergeist/issues/594). So use phantomjs 1.9.2 for headless testing.

Running integration tests with Internet Explorer is a little more complex. A windows computer is required, running IE >= 10.
This computer also needs to have Java, selenium-server-standalone, and IEDriver loaded. If it has a firewall, permissions must be configured sufficient to support this test configuration.
On the windows computer, start selenium-server with:
```
java -jar /path/to/selenium-server-standalone-xxx.jar -Dwebdriver.ie.driver=/path/to/IEDriverServer.exe -browser "browserName=internet explorer, version=11"
```

On the computer (typically a Mac) that is running the tests and the application, the spec_helper file includes Capybara configuration for remote IE testing. Uncomment the configuration as indicated in the file.
The computer on which Internet Explorer is running should also have pdf files for testing file upload. The following pdf files are required:
first_upload_file.pdf (size less than the configured size limit)
big_upload_file.pdf (size greater than configured size limit)
first_upload_image_file.png (for testing of unpermitted file upload check)

The computer 'driving' the test and hosting the application must have a running instance of the application, in the test environment. The Capybara config specifies port 3010. Initiate the app with rails server -e test -p 3010.

Two parameters related to the windows computer must be configured for Capybara: in the file lib/capybara_remote.rb, configure local values for the local network address of the windows computer, and the path to the test upload files (see above for which files are required to be present).

A couple of windows configurations must be set in order to support this test scenario:
1. Registry key configuration, see https://code.google.com/p/selenium/wiki/InternetExplorerDriver
2. If the tests, in particular the character entry in text fields, is running very slowsly, you may need to use the 32-bit version of IEDriverServer. See https://www.microsoft.com/en-us/download/details.aspx?id=44069
3. Zone permissions under the windows "Internet options" configuration menu may need to be configured to be the same for all zones.

### Javascript testing
In some cases test coverage of the javascript is achieved with integration testing by means of rspec features.
In other cases, dedicated javscript tests have been used. These use a suite of javascript test libraries, including:
* Teaspoon (https://github.com/modeset/teaspoon)
* MagicLamp (https://github.com/crismali/magic_lamp)
* Mocha (https://mochajs.org/)
* Chai (http://chaijs.com/)

#### Browser testing (slower, but facilitates debugging)
To run the javascript test suite, first start a rails server up in the special environment configured for javascript testing:
  rails s -e jstest -p 5000 -P `pwd`/tmp/pids/jstestserver.pid
This environment is configured for no asset caching, as in development environment. It has its own database, so that objects can be created and destroyed without affecting the development database, and also its own log (log/jstest.log).
Then point the browser to the teaspoon rack endpoint on that server:
  localhost:5000/en/teaspoon/testname
where testname is the name of the test suite you wish to run. The following js test suites are included:
* media
* corporate
* default (runs all other suites)

#### Headless testing (faster, but debugging is more difficult, use this for regression testing)
Requires phantomjs version 2.1.1 or later. From the application directory command line run
    RAILS_ENV=jstest teaspoon --suite media
or
    RAILS_ENV=jstest rake teaspoon suite=default

## Deployment
Development updates are pushed manually to a git repository, using the normal git push procedure.
Deployment is automated using the Capistrano gem using:
    cap production deploy
This pulls from the git repo to a cached copy on the server, copies the update to a into the 'releases' directory, and symlinks the 'current' directory to point to the most recent release.
The 5 most recent releases are kept on the server.
Capistrano deployment also symlinks the config/database.yml and lib/constants files to copies in the 'shared' directory.
These files contain sensitive information and should be manually copied into the 'shared' directory. This is typically done just once when the app is first installed, as the information will typically remain unchanged for the life of the app.
A list of all the files that the application requires to be present in the shared directory is found in the conifg/deploy_example.rb file.

## Configuring SSL
Letsencrypt (http://letsencrypt.org) may be used to obtain an ssl certificate. This is facilitated by the letsencrypt_plugin gem (https://github.com/lgromanowski/letsencrypt-plugin). This gem needs a configuration file, and it's stored in the shared/config/letsencrypt_plugin.yml where capistrano symlinks files. Refer to the gem's README for information on the parameters that must be included. The RSA private key is also symlinked by capistrano to shared/key/keyfile.pem.

After following the instructions on the letsencrypt_plugin gem, you will have ssl certificates for your site stored in the certificates directory.

Alternatively you may exclude this gem from Gemfile (and remove it from config/routes.rb) and obtain the site ssl certificate by another means.

## Customizing the theme

## Log rotation

## Document storage

## Modules
The application is structures as modules, located in the vendor/gems directory. The framework for a new module may be generated
with:
    rails generate nhridocs_module modname

This inserts the framework for a "modname" module as a Rails engine in the vendor/gems directory, and functionality may be added here as required.
Modules should configure all the routes required for navigation within the module, in the module's own config/routes.rb file.
A newly-generated module is connected into the application by
1. Complete the information in the engine's .gemspec file (required for bundler)
2. Add it to the Gemfile and install with the 'bundle' command
3. Add links to the top-level navigation menu (config/navigation.rb)
4. If it includes javascripts in its app/assets/javascript/modname/ directory, then //= require modname must be added to the app/javascripts/application.js of the main app.
Included modules may be excluded simply by deleting them from the vendor/gems library and removing the links from
the top-level navigation menu and removing it from the Gemfile.
Database migrations pertaining to the module's resources should be added in the module's own db/migrate directory. They
will be included and run with the main application's migrations.

## Shared Models
The root application includes models, controllers and views that appear in multiple modules, and may be included in new modules. They are:
1. Reminders
2. Notes
Each of these shared elements has a feature test spec implemented as an rspec shared behaviour. So the behaviour can be tested when the shared model is incorporated into a module.

## License
GPL V3, see LICENSE.txt
