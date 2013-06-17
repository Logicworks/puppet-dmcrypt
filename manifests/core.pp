##
# This class provides support for mounting LUKS encrypted devices.
#
# Usage:
#
#  class {'dmcrypt::core': }
#
#  dmcrypt::luksDevice {'/dev/vdb1':
#    name        => 'osd-1',
#    mount_point => '/var/lib/ceph/osd/ceph-1'
#  }
#
# ... and probably more calls to dmcrypt::luksDevice
#
class dmcrypt::core {
  package {['cryptsetup', 'xfsprogs','wipe']:
    ensure => installed
  }
}
