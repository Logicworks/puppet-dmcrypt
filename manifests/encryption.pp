# Class: dmcrypt::encryption
#
#
class dmcrypt::encryption {
    # resources

  $device = $title

  $secret_path = "puppet:///secrets/${title}"
  $key_file = "/root/${title}.key"

  file {$key_file:
    ensure  => present,
    mode    => '0600',
    source  => $secret_path,
  }

define dmcrypt::luksFormat($key_file) {
  $device = $title


  exec {"luksFormat-${device}":
    path    => '/bin:/usr/bin:/usr/sbin:/sbin',
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
  dmcrypt::luksFormat {$device:
    key_file => $key_file,
    notify   => Exec["format-${device}"]
  }

}