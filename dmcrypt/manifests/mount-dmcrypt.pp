  #
  #
  # mount-dmcrypt.pp
  # This will test a block devices to be a vailded dmcrypt devices, 
  # then try to mount it.
  # Need at least two variables.
  # <mount_point><dmcrypt_device> <dmcrypt_password>[<dmcrypt_name>]
  #
  # Additonaly we can add a name for the dmcrypt. Else it will called dmcrypt-devcies.
  # /dev/mapper/dmcrypt-sda
  #
  #



  # Define: Call block_devices_test
  # Parameters: devices
  #
  # It will use the cryptsetup. It's return true for a dmcryp devices.
  # false is return when not.
  # True has the exist status 0.
  # False has the exist status 1.

 define block_devices_test($device) {
     exec { "is_true_luksdevice":
        require => Package['cryptsetup'],
        command => "/sbin/cryptsetup isLuks /dev/$device",
     }
    }


  # Define: mount_point_test
  # Parameters: mount_point
  #
  # Checks for an existing mount point.
 define mount_point_test ($mount_point) {
    exec { "is_existing_mount_point":
        require => Exec['is_true_luksdevice'],
        command => "/usr/bin/test -d ${mount_point}",
    }
 }

 # Define: has_dmcrypt_name
 # Parameters: dmcrypt_name
 #
 define has_dmcrypt_name ($dmcrypt_name) {
    if $dmcrypt_name == 'undef' {
        $dcname = "dmcrypt-${device}"
    }
    else {
        $dcname = $dmcrypt_name
        notify {'after_else':
                message => "Content of ${dcname}"
            }
    }
 }


# Define: decrypt_and_mount
#:
# arguments
#
define decrypt_and_mount ($input_device, $input_mount_point, $input_dmcrypt_name, $input_dmcrypt_key) {

    block_devices_test {'test_sdb': device => "$input_device"}
    mount_point_test { 'test_osd_mountpoint_osd-1': mount_point => "${input_mount_point}"}
    has_dmcrypt_name { 'ceph_osd-1': dmcrypt_name => "${input_dmcrypt_name}"}

    exec { "decrypt_dmcrypt_device":
        require => Exec['is_existing_mount_point', 'is_true_luksdevice'],
        unless => "/sbin/cryptsetup status /dev/mapper/${input_dmcrypt_name}",
        command => "/bin/echo -n ${input_dmcrypt_key} |/sbin/cryptsetup luksOpen /dev/${input_device} ${input_dmcrypt_name} -d -",
    }
    exec { "mount_dmcrypt_device":
        require => Exec['decrypt_dmcrypt_device'],
        unless => "/bin/mount |grep '/dev/mapper/${input_dmcrypt_name}'",
        command => "/bin/mount /dev/mapper/${input_dmcrypt_name} ${input_mount_point}",
    }
}


# execute it for a test.
#dmcrypt::core{}
  package {'cryptsetup':
    ensure => installed
  }
decrypt_and_mount { 'mount_ceph_osd-1': input_device => 'sdb',
                                        input_mount_point => '/var/lib/ceph/osd/ceph-1',
                                        input_dmcrypt_name => 'CEPH-OSD.1',
                                        input_dmcrypt_key => 'asdfghjkl', }
