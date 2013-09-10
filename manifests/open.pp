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
    command => "/sbin/cryptsetup luksOpen /dev/${device} ${name} -d ${key_file}",
    creates => "/dev/mapper/${name}",
    require => Package['cryptsetup']
  }
}
