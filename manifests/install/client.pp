# Class: ipa::client
#
# This class configures an IPA client
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall, puppetlabs/stdlib
#
# Sample Usage:
#
class ipa::install::client {

  package{$ipa::ipa_client_package_name:
    ensure => present,
  }

  package{$ipa::kstart_package_name:
    ensure => present,
  }

  if $ipa::mkhomedir {
    $client_install_cmd_opts_mkhomedir = '--mkhomedir'
  } else {
    $client_install_cmd_opts_mkhomedir = ''
  }

  if $ipa::fixed_primary {
    $client_install_cmd_opts_fixed_primary = '--fixed-primary'
  } else {
    $client_install_cmd_opts_fixed_primary = ''
  }

  if $ipa::configure_ntp {
    $client_install_cmd_opts_no_ntp = ''
  } else {
    $client_install_cmd_opts_no_ntp = '--no-ntp'
  }

    $client_install_cmd = "\
/usr/sbin/ipa-client-install \
  --server=${ipa::ipa_master_fqdn} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --principal='${ipa::final_domain_join_principal}' \
  --password='${ipa::final_domain_join_password}' \
  ${client_install_cmd_opts_mkhomedir} \
  ${client_install_cmd_opts_fixed_primary} \
  ${client_install_cmd_opts_no_ntp} \
  --unattended"

  exec { "client_install_${::fqdn}":
    command   => $client_install_cmd,
    timeout   => 0,
    unless    => "cat /etc/ipa/default.conf | grep -i \"${ipa::domain}\"",
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    # notify    => Ipa::Helpers::Flushcache["client_${::fqdn}"],
    before    => Service['sssd'],
    provider  => 'shell',
  }

  if $ipa::install_sssd {
    service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package[$ipa::sssd_package_name],
    }
  }

  # Ipa::Clientinstall <<| |>> {
  #   name         => $::fqdn,
  #   otp          => $ipa::client::otp,
  #   domain       => $ipa::client::domain,
  #   mkhomedir    => $ipa::client::mkhomedir,
  #   ntp          => $ipa::client::ntp,
  #   fixedprimary => $ipa::client::fixedprimary,
  #   require      => Package[$ipa::client::clntpkg],
  # }

  # if $ipa::client::sudo {
  #   Ipa::Configsudo <<| |>> {
  #     name    => $::fqdn,
  #     os      => "${::osfamily}${::lsbmajdistrelease}",
  #     require => Ipa::Clientinstall[$::fqdn]
  #   }
  # }

  # if $ipa::client::automount {
  #   if $ipa::client::autofs {
  #     realize Service['autofs']
  #     realize Package['autofs']
  #   }
  #
  #   Ipa::Configautomount <<| |>> {
  #     name    => $::fqdn,
  #     os      => $::osfamily,
  #     notify  => Service['autofs'],
  #     require => Ipa::Clientinstall[$::fqdn]
  #   }
  # }

  # if defined(Package[$ipa::client::clntpkg]) {
  #   realize Package[$ipa::client::clntpkg]
  # }

  # if $ipa::client::ldaputils {
  #   if defined(Package[$ipa::client::ldaputilspkg]) {
  #     realize Package[$ipa::client::ldaputilspkg]
  #   }
  # }
  #
  # if $ipa::client::sssdtools {
  #   if defined(Package[$ipa::client::sssdtoolspkg]) {
  #     realize Package[$ipa::client::sssdtoolspkg]
  #   }
  # }
  #
  # if $ipa::client::sssd {
  #   Ipa::Clientinstall<||> -> Service['sssd']
  #   realize Package['sssd-common']
  #   realize Service['sssd']
  # }

  # if $::osfamily == 'Debian' {
  #   file { '/etc/pki':
  #     ensure  => 'directory',
  #     mode    => '0755',
  #     owner   => 'root',
  #     group   => 'root',
  #     require => Package[$ipa::client::clntpkg]
  #   }
  #
  #   file {'/etc/pki/nssdb':
  #     ensure  => 'directory',
  #     mode    => '0755',
  #     owner   => 'root',
  #     group   => 'root',
  #     require => File['/etc/pki']
  #   }
  #
  #   File['/etc/pki/nssdb'] -> Ipa::Clientinstall <<| |>>
  #
  #   if $ipa::client::sudo and $ipa::client::debiansudopkg {
  #     @package { 'sudo-ldap':
  #       ensure => installed
  #     }
  #     realize Package['sudo-ldap']
  #   }
  #
  #   if $ipa::client::mkhomedir == true {
  #     augeas {
  #       'mkhomedir_pam' :
  #         context => '/files/etc/pam.d/common-session',
  #         changes => ['ins 1000000 after *[last()]',
  #                     'set 1000000/type session',
  #                     'set 1000000/control required',
  #                     'set 1000000/module pam_mkhomedir.so',
  #                     'set 1000000/argument umask=0022'],
  #         onlyif  => 'match *[type="session"][module="pam_mkhomedir.so"][argument="umask=0022"] size == 0'
  #     }
  #   }
  # }

  # @@ipa::hostadd { $::fqdn:
  #   otp      => $ipa::client::otp,
  #   desc     => $ipa::client::desc,
  #   clientos => $::lsbdistdescription,
  #   clientpf => $::manufacturer,
  #   locality => $ipa::client::locality,
  #   location => $ipa::client::location
  # }

  # if $ipa::client::loadbalance {
  #   ipa::loadbalanceconf { "client-${::fqdn}":
  #     domain     => $ipa::client::domain,
  #     ipaservers => $ipa::client::ipaservers,
  #     mkhomedir  => $ipa::client::mkhomedir,
  #     require    => Ipa::Clientinstall[$::fqdn]
  #   }
  # }
}
