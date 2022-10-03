# The Classical Station Roku Channel

This is a minimal Roku channel to listen to
https://theclassicalstation.org.

The information about what's currently playing can be off a little.
It's based on the times on the playlist prepared before the programs,
but since all music is played by live announcers, the pieces may
start and end a minute or two ahead or behind of the plan.

## Packaging the channel

Docs at https://developer.roku.com/docs/developer-program/publishing/packaging-channels.md

### How to set up a Roku to use for packaging releases

Docs at https://developer.roku.com/docs/developer-program/publishing/packaging-channels.md#new-key-generation

1. Enable developer mode on the Roku. (Instructions available all over the place, so not copied here. e.g. https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md)

2. Telnet to port 8080 on the Roku.  E.g.:


    $ telnet 192.168.0.5 8080
    Trying 192.168.0.5...
    Connected to 192.168.0.5.
    Escape character is '^]'.
    ......... ({modelname} - {Roku OS Version})
    >


3. Enter "genkey" and hit Enter:


    >   genkey
    ......+++++
    ..........................................................................................
    ...................................+++++
    Password: xxxxxxxxxxxxxxxxxxxxxxxx
    DevID: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


4. RECORD the password and DevID for later use.

### How to make a new release

1. Edit manifest file:

   1. Increment minor_version
   1. Increment build_version
   1. Make sure "runTests=false"
   1. Commit to git, including "v{major_version}.{minor_version}.{build_version} in the commit message. E.g. v1.10.22

1. Package the channel into a signed .pkg file:

    1. Install onto a Roku. (https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md)

    1. Go to http://{roku_ip_address}. E.g. http://192.168.0.5

    1. Click the "Convert to cramfs" button

    1. On the same page, click "Packager" in the top right

    1. In "App name", enter "The Classical Station/{major_version}.{minor_version}.{build_version}", e.g. "The Classical Station/1.10.22"

    1. In the password field, enter the password recorded when the Roku was set up for packaging releases.

    1. Click "Package"

    1. You should now see on the page something like this, where the package filename is a link

            Currently Packaged Application:
            Pd0670dbdc81808d0a6f53d1a02f932fe.pkg
            package file (781232 bytes)

    1. Click the link to download the package file. Save it somewhere.

1. Upload the package file to developer.roku.com:

    1. Go to your developer dashboard at https://developer.roku.com (click Dashboard)

    1. Under "My Channels", click the channel you're releasing.

    1. **Next to** "Manage my Channels v", change the dropdown to "Package Upload".

    1. Enter the {major_version}.{minor_version}, click "Upload package" and select the package file previously downloaded from your Roku, check "I'm not a robot", and click "Submit".

1. Run Static Analysis:

    1. Scroll down until you can click on "Static Analysis".

    1. Click "Analyze". Wait 10-20 seconds. Click "Refresh". Repeat until the analysis is complete.

    1. Resolve any warnings or errors, then start the whole process over, until the analysis is clean.

1. Publish the new version:

    1. Next to "Manage my Channels v", change the dropdown to "Preview and Publish".

    1. Scroll down and click "Submit for publishing".
