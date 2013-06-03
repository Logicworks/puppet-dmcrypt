README.md

# About #

Basic decryption and mount with cryptsetup

Created basic implementation of a 'better' way of mount a block devices
via cryptsetup.

It's write to run only with the mount-dmcrypt.pp, files to turn it later into a module are created.
The manifest will check for all variables.
 <mount_point> does it exist?
 <device> is it a real luks devices?
 <dmcrypt_password> ToDO getting it from the Puppetmaster via puppet-secret
 <dmcrypt_name> Do we have it?

There are some more ToDo open.

 - Function to create file system.
 - Creating a (better) documentation.
 - Checking that the decryption process isn't logged to the local system or:
 - Ensure this is secure enough.(including puppet-secure)
 - Turn it into a real puppet module.([SMP-1919](https://midgard.intra.t-online.de/gard/browse/SMBCAP-1919))
 - Enable puppet-lint for more beauty.
 - Release it on github.
 - Stuff that I miss?



## Run it ##

To create a devices:

	puppet apply create-dmcrypt-devices.pp

To mount it:

	puppet apply mount-dmcrypt.pp

## Version ##

Test on a Ubuntu 12.04 with Puppet 3.2.1 and cryptsetup 1.4.1.



