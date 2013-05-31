 #
 #
 # Create.pp
 # Will create the mount point, will encrypt the block devices.
 # At last it will call the mount function an jack it into the system.

 #       create <name> <device>

              # Creates a mapping with <name> backed by device <device>.
              # <options> can be [--hash, --cipher, --verify-passphrase, --key-file, --keyfile-offset, --key-size, --offset, --skip, --size, --readonly, --shared, --allow-discards]
              # Example: 'cryptsetup create e1 /dev/sda10' maps the raw encrypted device /dev/sda10 to the mapped (decrypted) device /dev/mapper/e1, which can then be mounted, fsck-ed or have a filesystem created on
              # it.


# define dmcrypt::create_mountpoint{
# }

# Define: create_encryption
# Parameters:
# arguments
#
define create_encryption ($input_disk_to_encrypt, $input_dmcrypt_password) {
    exec { "encrypting_disk":
        unless => "/sbin/cryptsetup isLuks /dev/$device",
        command => "/bin/echo -n ${input_dmcrypt_password} | /sbin/cryptsetup -q  --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random luksFormat /dev/${input_disk_to_encrypt}",
    }
}

create_encryption { 'encryp_sdc': input_disk_to_encrypt => "sdc", input_dmcrypt_password => "asdfghjkl"}

# Need to create a fsck
