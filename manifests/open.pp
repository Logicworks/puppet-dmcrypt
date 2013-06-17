class dmcrypt::open($device, $name){

  $key_file = "/root/${device}.key"
  exec {"luksOpen-${device}":
    command => "/sbin/cryptsetup luksOpen /dev/${device} ${name} -d ${key_file}",
    creates => "/dev/mapper/${name}",
    require => Package['cryptsetup']
	}
}