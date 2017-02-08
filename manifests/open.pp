# Define: dmcrypt::open
#
# Open a dmcrypt device created before
#
# Set the $host_secret parameter if you want to use only
# one secret/key per host for all the later setup devices in
# this node.
#
# == Name
#   Unused
# == Parameters
# [*device*] The device to open as LUKS device
#   Mandatory.
#
# [*name*] The mapping name.
#   Mandatory.
#
# [*host_secret*] If one secret/key per host should be used
#   Optional. Defaults to 'false'
#
# == Dependencies
#
# Packages: cryptsetup
#
# == Authors
#
#  Jan Alexander Slabiak <j.slabiak@telekom.de>
#  Danny Al-Gaaf <d.al-gaaf@telekom.de>
#
# == Copyright
#
# Copyright 2013 Deutsche Telekom AG
#

define dmcrypt::open(
  $device,
  $name,
  $host_secret = false,
) {
  if $host_secret == true {
    $secret_name = "dmcrypt-${::hostname}"
  } else {
    $secret_name = "${device}"
  }

  $key_file = "/root/${secret_name}.key"
  exec {"luksOpen-${device}":
    path    => "/usr/sbin:/usr/bin:/sbin:/bin:",
    command => "cryptsetup luksOpen /dev/${device} ${name} -d ${key_file}",
    creates => "/dev/mapper/${name}",
    require => Package['cryptsetup-luks']
  }
}
