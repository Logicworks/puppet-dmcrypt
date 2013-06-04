About
=====

Decrypt and use LUKS encrypted device.

This module allows to decrypt and mount a LUKS encrypted device. If the device has not been formatted before, it is formatted with XFS. "not formatted before" means that the first 10 MB of the device are filled with zeroes.

Usage
=====

    class {'dmcrypt': }
    
    dmcrypt::luksDevice {'/dev/vdb1':
      name        => 'osd-1',
      mount_point => '/var/lib/ceph/osd/ceph-1'
    }

... and probably more calls to `dmcrypt::luksDevice`

Compatibility
=============

Works at least on Ubuntu 12.04 with puppet 2.7.11 and cryptsetup 1.4.1.



