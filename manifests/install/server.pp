# Definition: ipa::serverinstall
#
# Installs an IPA server
class ipa::install::server {

  package{$ipa::ipa_server_package_name:
    ensure => present,
  }

  package{$ipa::kstart_package_name:
    ensure => present,
  }

  $server_install_cmd_opts_idstart = "--idstart=${ipa::final_idstart}"

  if $ipa::enable_hostname {
    $server_install_cmd_opts_hostname = "--hostname=${ipa::ipa_server_fqdn}"
  } else {
    $server_install_cmd_opts_hostname = ''
  }

  if $ipa::enable_ip_address {
    $server_install_cmd_opts_ip_address = "--ip-address ${ipa::ip_address}"
  } else {
    $server_install_cmd_opts_ip_address = ''
  }

  if $ipa::use_external_ca {
    $server_install_cmd_opts_external_ca = '--external-ca'
  } else {
    $server_install_cmd_opts_external_ca = ''
  }

  if $ipa::final_configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $ipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $ipa::final_configure_dns_server {
    if size($ipa::custom_dns_forwarders) > 0 {
      $server_install_cmd_opts_forwarders = join(
        prefix(
          $ipa::custom_dns_forwarders,
          '--forwarder '),
        ' '
      )
    }
    else {
      $server_install_cmd_opts_forwarders = '--no-forwarders'
    }
  }
  else {
    $server_install_cmd_opts_forwarders = ''
  }

  if $ipa::no_ui_redirect {
    $server_install_cmd_opts_no_ui_redirect = ''
  } else {
    $server_install_cmd_opts_no_ui_redirect = '--no-ui-redirect'
  }

  if $ipa::ipa_role == 'master' {
    contain 'ipa::install::server::master'
  } elsif $ipa::ipa_role == 'replica' {
    contain 'ipa::install::server::replica'
  }

  ensure_resource (
    'service',
    'httpd',
    {ensure => 'running'},
  )

  contain 'ipa::config::webui'

  service { 'ipa':
    ensure  => 'running',
    enable  => true,
    require => Exec["server_install_${ipa::ipa_server_fqdn}"],
  }

  if $ipa::install_sssd {
    service { 'sssd':
      ensure  => 'running',
      enable  => true,
      require => Package[$ipa::sssd_package_name],
    }
  }

  # TODO: might require relationship
  ipa::helpers::flushcache { "server_${ipa::ipa_server_fqdn}": }
  class {'ipa::config::admin_user': }

}
