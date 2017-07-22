# Class: ipa::install::server::replica
#
class ipa::install::server::replica {

  $replica_install_cmd = "\
/usr/sbin/ipa-replica-install \
  --principal=${ipa::final_domain_join_principal} \
  --admin-password='${ipa::final_domain_join_password}' \
  ${ipa::install::server::server_install_cmd_opts_hostname} \
  --realm=${ipa::final_realm} \
  --domain=${ipa::domain} \
  --server=${ipa::ipa_master_fqdn} \
  ${ipa::install::server::server_install_cmd_opts_setup_dns} \
  ${ipa::install::server::server_install_cmd_opts_forwarders} \
  ${ipa::install::server::server_install_cmd_opts_ip_address} \
  ${ipa::install::server::server_install_cmd_opts_no_ntp} \
  ${ipa::install::server::server_install_cmd_opts_no_ui_redirect} \
  --unattended"

  # ${ipa::install::server::server_install_cmd_opts_external_ca} \

  # TODO: config-show and grep for IPA\ masters
  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
  }
  -> exec { "server_install_${ipa::ipa_server_fqdn}":
    command   => $replica_install_cmd,
    timeout   => 0,
    unless    => '/usr/sbin/ipactl status >/dev/null 2>&1',
    creates   => '/etc/ipa/default.conf',
    logoutput => 'on_failure',
    notify    => Ipa::Helpers::Flushcache["server_${ipa::ipa_server_fqdn}"],
    before    => Service['sssd'],
  }
  -> cron { 'k5start_root':
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package[$ipa::kstart_package_name],
  }

}
