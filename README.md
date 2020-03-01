# Address Book Pictures

Address Book Pictures is (as it's name states) an application to add images to your macOS Address Book. The current version of Address Book Pictures only uses LDAP servers as a source of images.

## How To Use

The basic process for using Address Book Pictures is:

1.	define a configuration for an LDAP server
2. test the connection
3. open connection to view available photos
4. set update action and synchronize pictures to Address Book

## Define and Test Configuration

This is by far the hardest part of the process but once done, can be used over and over to refresh new pictures into your Address Book. Start by selecting "Configurations" under the "Window" menu. Under the gear icon choose "Add LDAP Connection." Connections to LDAP servers typically have this information to define them:

* Host and Port: The host can be a hostname or IP address. The port, if left blank, will use the LDAP default.
* Authentication Type, Username and Password: For a public LDAP server this can be left blank. For LDAP servers that require authentication you'll need to enter your account information here.
* Search Base: An LDAP server is like a big tree of information and the search base is the place to start looking for "people" records.
* Search Filter: A filter allows you to reduce the number of results that come back. You can filter on specific user names or wild carded email addresses.

Determining the LDAP connection can be the most frustrating part of this. If you already have an LDAP connection in Address Book you can copy the settings to Address Book Pictures. Or, if you have an internal IT department that may be good place to start.

Once you have a configuration entered you can test the connection which will display the user name and emails. Once tested, select "Open Connection" to get pictures synchronizing.

**_WARNING: In this beta release, all passwords are stored in plain text._**

## Open Connection and Synchronize

When you open a connection a new window will open which will cross reference the LDAP results with your address book for those LDAP records that have pictures. For each record you can either update it with the photo or skip it. Buttons at the bottom will assist in selecting all or none to update. Using the "Update Blank" button will only set those Address Book records with no photo to import.

Once you have an action set for each record, click "Synchronize" to run through the actions for each record. Once finished, your Address Book will be updated.

## Compatibility

There are some differences between LDAP servers and the application may need to be updated to account for those differences. If you know your LDAP server has pictures but Address Book Pictures can't pull them out, I would love to know more about what your LDAP server vendor/version is.

## More LDAP Tips

If you're familiar with the command line, you can sometimes figure out your LDAP search base by using the ldapsearch command line. Here is an example:

```
$ ldapsearch -x -h you.ldapserver.local -b "" -s base "objectclass=*"
```

Look for a line like one of the following:

```
namingContexts: DC=YourDomain,DC=local
namingContexts: o=Your Company or University,c=US
```

Enter that information (minus the "namingContexts:" part) into the search base and give it a try. Hope that helps!

## Known Issues

* This code is from 2012-2014 and needs an audit of deprecated APIs
* The LDAP libraries have options to page through results. Currently the app uses calls to bring back all results at once. If your query brings back too many results the app can't handle it.
