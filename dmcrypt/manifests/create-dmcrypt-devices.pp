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
define create_encryption ($input_disk_to_encrypt, $input_dmcrypt_key_file) {
    exec { 'encrypting_disk':
        # Test that the current volume is a luks devices, return true when it's.
        # Else false(exit code 1) is return.
        # When -v is added, human reable output will be displayed. Not need here.

        unless  => "/sbin/cryptsetup isLuks /dev/${input_disk_to_encrypt}",

        # Secure way of encryption. Maybe we should have run of randoms values over disk?
        # Need to get the secret file form puppet-secret first.
        # Note:
        #       It's preferred to use --use-random, but this requirer user input.
        #       This let the system hang sometimes. To prevent this --use-urandom is used.
        #       @DK: fine for you?

        command => "/sbin/cryptsetup -q \
          --cipher aes-xts-plain64 \
          --key-size 512 \
          --hash sha512 \
          --iter-time 5000 \
          --use-urandom \
          --key-file ${input_dmcrypt_key_file} \
          luksFormat /dev/${input_disk_to_encrypt}",
    }
}


create_encryption { 'encrypt_sdc':
                                input_disk_to_encrypt  => "sdc",
                                input_dmcrypt_key_file => "/tmp/CEPH-OSD.3.key"
                            }

# Need to create a filesystem.
