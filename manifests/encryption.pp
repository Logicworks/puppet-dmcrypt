# Class: dmcrypt::encryption
#
#
define dmcrypt::encryption ($device) {
    # resources

  $secret = secret($device, {
          'length' => 16,
          'method' => 'alphabet'
          })

  $secret_path = "puppet:///secrets/${device}"
  $key_file = "/root/${device}.key"

  file {$key_file:
    ensure  => present,
    mode    => '0600',
    source  => $secret_path,
  }

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
