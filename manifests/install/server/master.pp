# Class: ipa::install::server::master
#
# This class configures an IPA master
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall, puppetlabs/stdlib
#
# Sample Usage:
#

#
class ipa::install::server::master {
  # Install
  $server_install_cmd = "\
/usr/sbin/ipa-server-install \
  ${ipa::install::server::server_install_cmd_opts_hostname} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --admin-password='${ipa::admin_password}' \
  --ds-password='${ipa::directory_services_password}' \
  ${ipa::install::server::server_install_cmd_opts_setup_dns} \
  ${ipa::install::server::server_install_cmd_opts_forwarders} \
  ${ipa::install::server::server_install_cmd_opts_ip_address} \
  ${ipa::install::server::server_install_cmd_opts_no_ntp} \
  ${ipa::install::server::server_install_cmd_opts_external_ca} \
  ${ipa::install::server::server_install_cmd_opts_idstart} \
  ${ipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  --unattended"

  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
  }
  -> exec { "server_install_${ipa::ipa_server_fqdn}":
    command   => $server_install_cmd,
    timeout   => 0,
    unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    notify    => Ipa::Helpers::Flushcache["server_${ipa::ipa_server_fqdn}"],
    before    => Service['sssd'],
  }
  -> cron { 'k5start_root': #allows scp to replicas as root
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package[$ipa::kstart_package_name],
  }

}
