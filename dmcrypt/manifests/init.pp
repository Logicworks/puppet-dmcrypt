##
# This class provides support for mounting LUKS encrypted devices.
#
# Usage:
#
#  class {'dmcrypt': }
#
#  dmcrypt::luksDevice {'/dev/vdb1':
#    name        => 'osd-1',
#    mount_point => '/var/lib/ceph/osd/ceph-1'
#  }
#
# ... and probably more calls to dmcrypt::luksDevice
#
class dmcrypt {
  package {['cryptsetup', 'xfsprogs','wipe']:
    ensure => installed
  }
}

##
# This is a helper function
#
# Performs a 'cryptsetup luksFormat' for the given device iff the device is
# empty, which is defined as "the first 10 MB contain only zeroes".
#
# Parameter:
#  $title    = device to format
#  $key_file = file containing the key to use
#
# Postcondition:
#  the device is a formatted LUKS device
define dmcrypt::luksFormat($key_file) {
  $device = $title

  exec {"luksFormat-${device}":
    path    => "/bin:/usr/bin:/usr/sbin:/sbin",
    command => "cryptsetup -q \
                --cipher aes-xts-plain64 \
                --key-size 512 \
                --hash sha512 \
                --use-urandom \
                --key-file ${key_file} \
                luksFormat ${device}",
    onlyif  => "test f1c9645dbc14efddc7d8a322685f26eb = \
                $(dd if=${device} bs=1k count=10k 2>/dev/null \
                | md5sum - | cut -f1 -d' ')",
    require => Package['cryptsetup']
  }
}

##
# This is a helper function
#
# performs a 'cryptsetup luksOpen' for the given device
#
# Parameter:
#  $title    = device to decrypt
#  $name     = name to assign to the decrypted device
#  $key_file = file containing the key to use
#
# Postcondition:
#  The device is decrypted and available as the given name
define dmcrypt::luksOpen($name, $key_file) {
  $device = $title

  exec {"luksOpen-${device}":
    command => "/sbin/cryptsetup luksOpen ${device} ${name} -d ${key_file}",
    creates => "/dev/mapper/${name}",
    require => Package['cryptsetup']
  }
}

##
# Decrypts and mounts the given device at the given mount point
#
# If the device is empty (i.e. first 10 MB are zeroed) then it is formatted
# with both luksFormat and mkfs.xfs.
#
# Parameter:
#  $title       = device to use
#  $name        = name to assign to the decrypted device
#  $key_file    = file containing the key to use
#  $mount_point = where to mount the device
#
# Postcondition:
#  The given device is decrypted and available a the given mountpoint
define dmcrypt::luksDevice($name, $mount_point) {
  $device = $title

  dmcrypt::luksFormat {$device:
    key_file => "/tmp/${name}.key",
    notify   => Exec["format-${device}"]
  }
  -> dmcrypt::luksOpen {$device:
    name     => $name,
    key_file => "/tmp/${name}.key",
  }
  ~> mount {$mount_point:
    ensure    => mounted,
    atboot    => false,
    device    => "LABEL=${name}",
    fstype    => 'auto',
    options   => 'noauto',
    subscribe => Exec["format-${device}"]
  }

  exec {"format-${device}":
    command => "mkfs.xfs -L ${name} /dev/mapper/${name}",
    path    => "/bin:/usr/bin:/usr/sbin:/sbin",
    require => [Package['xfsprogs'], Exec["luksOpen-${device}"]],
    refreshonly => true
  }
}