#
# == Class: easy_ipa::install::client::debian
#
# Ensure that home directories get created on Debian and Ubuntu clients. This
# code is needed as the --mkhomedir parameter passed to ipa-client-install does
# not configure PAM even though it does install the required packages.
#
# Currently Ubuntu 14.04/16.04 and Debian 8/9 are supported.
#
class easy_ipa::install::client::debian {

  $mkhomedir_line = $facts['os']['distro']['codename'] ? {
    /^(xenial|stretch)$/ => 'session optional /lib/x86_64-linux-gnu/security/pam_oddjob_mkhomedir.so',
    /^(trusty|jessie)$/  => 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022',
  }

  file_line { 'mkhomedir':
    ensure => 'present',
    path   => '/etc/pam.d/common-session',
    line   => $mkhomedir_line,
    after  => '^# end of pam-auth-update config',
  }
}
