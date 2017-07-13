# Definition: ipa::serverinstall
#
# Installs an IPA server
class ipa::install::server {

  package{$ipa::ipa_server_package_name:
    ensure => present,
  }

  if $ipa::idstart {
    $final_idstart = $ipa::idstart
  } else {
    $final_idstart = fqdn_rand('10737') + 10000
  }
  $server_install_cmd_opts_idstart = "--idstart=${final_idstart}"

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

  if $ipa::configure_dns_server {
    $server_install_cmd_opts_setup_dns = '--setup-dns'
  } else {
    $server_install_cmd_opts_setup_dns = ''
  }

  if $ipa::configure_ntp {
    $server_install_cmd_opts_no_ntp = ''
  } else {
    $server_install_cmd_opts_no_ntp = '--no-ntp'
  }

  if $ipa::configure_dns_server {
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

  $server_install_cmd = "\
/usr/sbin/ipa-server-install \
  ${server_install_cmd_opts_hostname}    \
  --realm=${ipa::realm} \
  --domain=${ipa::domain} \
  --admin-password='${ipa::admin_password}' \
  --ds-password='${ipa::directory_services_password}' \
  ${server_install_cmd_opts_setup_dns} \
  ${server_install_cmd_opts_forwarders} \
  ${server_install_cmd_opts_ip_address} \
  ${server_install_cmd_opts_no_ntp} \
  ${server_install_cmd_opts_external_ca} \
  ${server_install_cmd_opts_idstart} \
  --unattended"

  exec { "serverinstall-${ipa::ipa_server_fqdn}":
    command   => $server_install_cmd,
    timeout   => 0,
    unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates   => '/etc/ipa/default.conf',
    # notify    => Ipa::Flushcache["server-${ipa::ipa_server_fqdn}"],
    logoutput => 'on_failure'
  }

  # ipa::flushcache { "server-${ipa::ipa_server_fqdn}":
  #   notify  => Ipa::Adminconfig[$ipa::ipa_server_fqdn],
  #   require => Anchor['ipa::serverinstall::start']
  # }
  #
  # ipa::adminconfig { $ipa::ipa_server_fqdn:
  #   realm   => $ipa::realm,
  #   idstart => $ipa::idstart,
  #   require => Anchor['ipa::serverinstall::start']
  # }
  #
  # anchor { 'ipa::serverinstall::end':
  #   require => [Ipa::Flushcache["server-${ipa::ipa_server_fqdn}"], Ipa::Adminconfig[$ipa::ipa_server_fqdn]]
  # }

}
