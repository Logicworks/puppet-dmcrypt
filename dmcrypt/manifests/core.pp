 # core.pp
 #

define dmcrypt::core{

  package {'cryptsetup':
    ensure => installed
  }
}
