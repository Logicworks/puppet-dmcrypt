# Class: dmcrypt::key
#
#
define dmcrypt::key (
  $key_name,
  $custom_secret    = undef,
) {
  # resources
  $key_file = "/root/${key_name}.key"
  if $custom_secret {
    file {$key_file:
      ensure  => present,
      mode    => '0600',
      content => "${custom_secret}" ,
    }
  } else {
    $secret = secret($key_name, {
            'length' => 16,
            'method' => 'alphabet'
            })

    $secret_path = "puppet:///secrets/${key_name}"

    file {$key_file:
      ensure  => present,
      mode    => '0600',
      source  => $secret_path,
    }
  }
}
