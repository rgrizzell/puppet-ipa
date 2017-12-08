#
# == Class: easy_ipa::install::client::debian
#
# Enable PAM configuration on recent Debian and Ubuntu clients. This is needed 
# as the --mkhomedir parameter passed to ipa-client-install does not configure
# PAM even though it does install the required packages.
#
# Currently only Ubuntu 16.04 and Debian 9 are supported. This is because older 
# Debian-based distros don't have the oddjob or oddjob-mkhomedir packages in 
# their repositories.
#
class easy_ipa::install::client::debian {

  case $facts['os']['distro']['codename'] {
    /^(xenial|stretch)$/: {
      file_line { 'pam_oddjob_mkhomedir.so':
        ensure => 'present',
        path   => '/etc/pam.d/common-session',
        line   => 'session optional /lib/x86_64-linux-gnu/security/pam_oddjob_mkhomedir.so',
        after  => '^# end of pam-auth-update config',
      }
    }
  }
}
