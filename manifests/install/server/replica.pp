# Class: ipa::replica
#
# This class configures an IPA replica
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall, puppetlabs/stdlib
#
# Sample Usage:
#
class ipa::install::server::replica {

  # if $enable_firewall {
  #   Class['ipa::client'] -> Ipa::Masterprincipal <<| tag == "ipa-master-principal-${ipa::replica::domain}" |>> -> Ipa::Replicapreparefirewall <<| tag == "ipa-replica-prepare-firewall-${ipa::replica::domain}" |>> -> Ipa::Masterreplicationfirewall <<| tag == "ipa-master-replication-firewall-${ipa::replica::domain}" |>> -> Ipa::Replicainstall[$::fqdn] -> Service['ipa']
  #
  #   Ipa::Replicapreparefirewall <<| tag == "ipa-replica-prepare-firewall-${ipa::replica::domain}" |>>
  #   Ipa::Masterreplicationfirewall <<| tag == "ipa-master-replication-firewall-${ipa::replica::domain}" |>>
  #   Ipa::Masterprincipal <<| tag == "ipa-master-principal-${ipa::replica::domain}" |>>
  # }else {
  #   Class['ipa::client'] -> Ipa::Replicainstall[$::fqdn] -> Service['ipa']
  # }
  #
  # if $::osfamily != 'RedHat' {
  #   fail("Cannot configure an IPA replica server on ${::operatingsystem} operating systems. Must be a RedHat-like operating system.")
  # }

  # realize Package[$ipa::replica::svrpkg]

  # realize Service['ipa']

  # if $ipa::replica::kstart {
  #   realize Package['kstart']
  # }
  #
  # if $ipa::replica::sssd {
  #   realize Package['sssd-common']
  #   realize Service['sssd']
  # }
  #
  # if $enable_firewall {
  #   firewall { '101 allow IPA replica TCP services (kerberos,kpasswd,ldap,ldaps)':
  #     ensure => 'present',
  #     action => 'accept',
  #     proto  => 'tcp',
  #     dport  => ['88','389','464','636']
  #   }
  #
  #   firewall { '102 allow IPA replica UDP services (kerberos,kpasswd,ntp)':
  #     ensure => 'present',
  #     action => 'accept',
  #     proto  => 'udp',
  #     dport  => ['88','123','464']
  #   }
  #
  #   @@ipa::replicareplicationfirewall { $::fqdn:
  #     source => $::ipaddress,
  #     tag    => "ipa-replica-replication-firewall-${ipa::replica::domain}"
  #   }
  #
  #   @@ipa::replicaprepare { $::fqdn:
  #     dspw => $ipa::replica::dspw,
  #     tag  => "ipa-replica-prepare-${ipa::replica::domain}"
  #   }
  # }
# Definition: ipa::replicainstall
#
# Installs an IPA replica
#   define ipa::replicainstall (
#     $host    = $name,
#     $adminpw = {},
#     $dspw    = {}
#   ) {
#
#     $file = "/var/lib/ipa/replica-info-${host}.gpg"
#
#     Exec["replicainfocheck-${host}"] ~> Exec["clientuninstall-${host}"] ~> Exec["replicainstall-${host}"] ~> Exec["removereplicainfo-${host}"]
#
#     exec { "replicainfocheck-${host}":
#       command   => "/usr/bin/test -e ${file}",
#       tries     => '60',
#       try_sleep => '60',
#       unless    => '/usr/sbin/ipactl status >/dev/null 2>&1'
#     }
#
#     exec { "clientuninstall-${host}":
#       command     => '/usr/sbin/ipa-client-install --uninstall --unattended',
#       refreshonly => true
#     }

  #   --password '${ipa::final_domain_join_password}' \
  #   --admin-password='${ipa::admin_password}' \
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
  ${ipa::install::server::server_install_cmd_opts_external_ca} \
  --unattended"

  # TODO: config-show and grep for IPA\ masters
#   $replica_install_cmd_unless = "\
# /usr/bin/ipa config-show
# "

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
  -> cron { 'k5start_root': #allows scp to replicas as root
    command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
    user    => 'root',
    minute  => '*/1',
    require => Package[$ipa::kstart_package_name],
  }

}
