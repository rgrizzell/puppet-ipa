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
  ## Install

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
  --unattended"

  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
  }
  -> exec { "serverinstall_${ipa::ipa_server_fqdn}":
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

  # File['/etc/ipa/primary']
  # -> class {'ipa::host_add':}
  # -> class {'ipa::replica_prepare':}
  # -> Ipa::Createreplicas[$ipa::ipa_server_fqdn]
  #
  # Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::domain}" |>>
  # class {'ipa::hostadd':}

  # if $ipa::install_kstart {
  #   realize Package[$ipa::kstart_package_name]
  #   # TODO: Why?? -- to allow scp to/from replicas as root

  # }

  # if $extca {
  #   class { 'ipa::master_extca':
  #     extcertpath   => $ipa::master::extcertpath,
  #     extcert       => $ipa::master::extcert,
  #     extcacertpath => $ipa::master::extcacertpath,
  #     extcacert     => $ipa::master::extcacert,
  #     dirsrv_pkcs12 => $ipa::master::dirsrv_pkcs12,
  #     http_pkcs12   => $ipa::master::http_pkcs12,
  #     dirsrv_pin    => $ipa::master::dirsrv_pin,
  #     http_pin      => $ipa::master::http_pin,
  #     subject       => $ipa::master::subject,
  #     selfsign      => $ipa::master::selfsign,
  #     require       => Ipa::Serverinstall[$::fqdn]
  #   }
  # } else {
  #   class { 'ipa::service':
  #     require => Ipa::Serverinstall[$::fqdn]
  #   }
  # }

  # ipa::createreplicas { $::fqdn:
  # }
  #
  # if $ipa::enable_firewall {
  #   firewall { '101 allow IPA master TCP services (http,https,kerberos,kpasswd,ldap,ldaps)':
  #     ensure => 'present',
  #     action => 'accept',
  #     proto  => 'tcp',
  #     dport  => ['80','88','389','443','464','636']
  #   }
  #
  #   firewall { '102 allow IPA master UDP services (kerberos,kpasswd,ntp)':
  #     ensure => 'present',
  #     action => 'accept',
  #     proto  => 'udp',
  #     dport  => ['88','123','464']
  #   }
  #
  #   @@ipa::replicapreparefirewall { $::fqdn:
  #     source => $::ipaddress,
  #     tag    => "ipa-replica-prepare-firewall-${ipa::master::domain}"
  #   }
  #
  #   @@ipa::masterreplicationfirewall { $::fqdn:
  #     source => $::ipaddress,
  #     tag    => "ipa-master-replication-firewall-${ipa::master::domain}"
  #   }
  #
  #   @@ipa::masterprincipal { $::fqdn:
  #     realm => $ipa::master::realm,
  #     tag   => "ipa-master-principal-${ipa::master::domain}"
  #   }
  # }

  # @@ipa::clientinstall { $::fqdn:
  #   masterfqdn => $::fqdn,
  #   domain     => $ipa::master::domain,
  #   realm      => $ipa::master::realm,
  #   adminpw    => $ipa::master::adminpw,
  #   otp        => '',
  #   mkhomedir  => '',
  #   ntp        => ''
  # }
#   if $ipa::master::loadbalance {
#     ipa::loadbalanceconf { "master-${::fqdn}":
#       domain     => $ipa::master::domain,
#       ipaservers => $ipa::master::ipaservers,
#       mkhomedir  => $ipa::master::mkhomedir,
#       require    => Ipa::Serverinstall[$::fqdn]
#     }
#   }
}
