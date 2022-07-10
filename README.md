# The Classical Station Roku Channel

This is a minimal roku channel to listen to
https://theclassicalstation.org.

## How to set up a Roku to use for packaging releases

1. Enable developer mode on the Roku. (Instructions available all over the place, so not copied here.)

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

## How to make a new release

1. Edit manifest:

   1. Increment minor_version
   2. Increment build_version
   3. Make sure "runTests=false"
   4. Commit, including "v{major_version}.{minor_version}.{build_version} in the commit message. E.g. v1.10.22

2. Install onto a Roku

3. Go to http://{roku_ip_address}. E.g. http://192.168.0.5

4. Click the "Convert to cramfs" button

5. On the same page, click "Packager" in the top right

6. In "App name", enter "The Classical Station/{major_version}.{minor_version}.{build_version}", e.g. "The Classical Station/1.10.22"

7. In the password field, enter the password recorded when the Roku was set up for packaging releases.

8. Click "Package"

9. You should now see on the page something like this, where the package filename is a link


    Currently Packaged Application:
    Pd0670dbdc81808d0a6f53d1a02f932fe.pkg
    package file (781232 bytes)


10. Click the link to download the package file. Save it somewhere.

11. Go to your developer dashboard at https://developer.roku.com/dev/dashboard?

12. Under "My Channels", click the channel you're releasing.

13. Next to "Manage my Channels v", change the dropdown to "Package Upload".

14. Enter the {major_version}.{minor_version}, click "Upload package" and select the package file previously downloaded from your Roku, check "I'm not a robot", and click "Submit".

15. Scroll down until you can click on "Static Analysis".

16. Click "Analyze". Wait 10-20 seconds. Click "Refresh". Repeat until the analysis is complete.
