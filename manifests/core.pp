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
class dmcrypt::core (
  $host_secret = false,
  $secret      = undef,
){
  package {['cryptsetup','wipe']:
    ensure => installed
  }

  if $host_secret == true {
    # in this case already defined!
    $secret_name = "dmcrypt-${::hostname}"

    dmcrypt::key { "${secret_name}":
      key_name      => $secret_name,
      custom_secret => $secret,
    }
  }

}
