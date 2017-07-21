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
}
