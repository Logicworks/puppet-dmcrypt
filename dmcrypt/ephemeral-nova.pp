define ephemeral_nova() {
  $device = $title

  file {'/etc/crypttab':
    ensure  => present,
    mode    => '0600',
    content => "nova $device /dev/urandom cipher=aes-xts-plain64,size=256,hash=sha512"
  }

  package {'cryptsetup':
    ensure => installed
  }

  mount {'/var/lib/nova/instances':
    ensure  => present,
    atboot  => false,
    device  => '/dev/mapper/nova',
    fstype  => 'auto',
    options => 'noauto'
  }

  file {'/etc/init/mount-nova.conf':
    ensure  => present,
    mode    => '0644',
    source  => 'puppet:///modules/dtagcloud/nova/mount-nova.conf',
    require => [File['/etc/crypttab'],
                Package['cryptsetup'],
                Mount['/var/lib/nova/instances']],
  }

  exec {'/usr/sbin/service mount-nova start':
    require   => File['/etc/init/mount-nova.conf'],
    subscribe => File['/etc/init/mount-nova.conf'],
    unless    => '/usr/bin/test -d /var/lib/nova/instances/lost+found'
  }
}
