# The Classical Station Roku Channel

This is a minimal Roku channel to listen to
https://theclassicalstation.org.

The information about what's currently playing can be off a little.
It's based on the times on the playlist prepared before the programs,
but since all music is played by live announcers, the pieces may
start and end a minute or two ahead or behind of the plan.

## Roku Programming

An overview to Roku Programming starts at https://developer.roku.com/docs/developer-program/getting-started/roku-dev-prog.md.

Reference documentation for the Roku API is at https://developer.roku.com/docs/references/references-overview.md.

## About Roku development keys

When you run "genkey" on a Roku device, it creates a new Roku
development key, and displays a key ID and a password. The key
itself stays on the Roku device. Just having the key ID and the
password is *not* enough information to package channels using
the same key on another device.

When you *package* a channel on a device, the device's currently
installed key is included in the package in such a way that
another Roku device can extract it if you provide the password.
Encryption hardware on the Roku devices is involved, so in theory,
there's no other way to get at the key. Even then, it
just gets the key onto the Roku device. You don't have it yourself.

Because of this, you must not only securely save the key ID and
password, but some channel packaged using the corresponding key.
Then if you need to package your channel again using the same
key as before and you don't have the original Roku (or it has
a different key now), you can upload the old package and provide the password to the Roku's rekey utility and install the original
key on the new Roku.

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

Note: if you want to package this channel using the same key
as previously, you'll also need to *rekey* the Roku device
before packaging.  But I think you have to have some key on
the device before you can do that. (Maybe?)

### How to make a new release

1. Edit manifest file:

   1. Increment minor_version
   1. Increment build_version
   1. Make sure "runTests=false"
   1. Commit to git, including "v{major_version}.{minor_version}.{build_version} in the commit message. E.g. v1.10.22

1. Package the channel into a signed .pkg file:

    1. Install onto a Roku. (https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md)

    1. Go to http://{roku_ip_address}. E.g. http://192.168.0.5. Login with your Roku's developer ID.

    1. OPTIONAL: Click the "Convert to squashfs" button. (I used to use "Convert to cramfs" but that seems to have gone away.)  That will make the downloaded package smaller, but breaks compatibility with the oldest Rokus. I have started not converting to squashfs, because I want the broadest device support.

    1. On the same page, click "Packager" in the top right

    1. In "App name", enter "The Classical Station/{major_version}.{minor_version}.{build_version}", e.g. "The Classical Station/1.10.22"

    1. In the password field, enter the key password.

    1. Click "Package"

    1. You should now see on the page something like this, where the package filename is a link

            Currently Packaged Application:
            Pd0670dbdc81808d0a6f53d1a02f932fe.pkg
            package file (781232 bytes)

    1. Click the link to download the package file. Save it somewhere.

1. Upload the package file to developer.roku.com:

    1. Go to your developer dashboard at https://developer.roku.com (click Dashboard) or go directly to https://developer.roku.com/dev/dashboard (unless Roku has reorganized their site again).

    1. Under "My Channels", click the channel you're releasing.

    1. Under "Package and testing", click "Channel package".

    1. Under "Upload your .pkg or .zip file", click "Upload", and select the .pkg file you downloaded previously.  *You do not need to click Upload again, the file is already uploaded.*

    1. At the bottom right, click "Save and run Static Analysis"

    1. Wait until the page stops flashing and the "Run Analysis" button is active. *You do not need to click the Run Analysis button. The analysis has already happened.*

    1. Toward the top of the page, look for the breadcrumb display something like "Public channels/The Classical Station (WCPE)/Static analysis" and click on your channel name.

    1. If you don't see any red or warnings, click "Schedule publish" in the top right.

    1. Pick a date/time to publish the updated channel. The earliest time available might be a week or more in the future. That's just how Roku channel publishing seems to work.

    1. Follow the rest of the prompts to finish scheduling release of the updated channel.
