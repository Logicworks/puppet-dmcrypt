# Class: dmcrypt::encryption
#
#
define dmcrypt::encryption (
  $device,
  $host_secret = false,
  $secret      = undef,
) {
  # resources
  if $host_secret == true {
    # in this case already defined!
    $secret_name = "dmcrypt-${::hostname}"
  } else {
    $secret_name = "${device}"

    dmcrypt::key { "${secret_name}":
      key_name      => $secret_name,
      custom_secret => $secret,
    }
  }

  $key_file = "/root/${secret_name}.key"

  exec {"luksFormat-${device}":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
    command => "cryptsetup -q \
                --cipher aes-xts-plain64 \
                --key-size 512 \
                --hash sha512 \
                --use-urandom \
                --key-file ${key_file} \
                luksFormat /dev/${device}",
    onlyif  => "test f1c9645dbc14efddc7d8a322685f26eb = \
                $(dd if=/dev/${device} bs=1k count=10k 2>/dev/null \
                | md5sum - | cut -f1 -d' ')",
    require => [ Package['cryptsetup'], File["${key_file}"] ]
  }
}
