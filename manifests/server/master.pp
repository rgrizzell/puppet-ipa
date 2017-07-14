# Class: ipa::master
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
class ipa::master {

  # if $ipa::enable_firewall {
  #   # TODO: firewall based on exported resources
  # }

  Ipa::Serverinstall[$ipa::ipa_server_fqdn]
  -> File['/etc/ipa/primary']
  -> class {'ipa::host_add':}
  -> class {'ipa::replica_prepare':}
  -> Ipa::Createreplicas[$ipa::ipa_server_fqdn]

  Ipa::Replicaprepare <<| tag == "ipa-replica-prepare-${ipa::domain}" |>>
  class {'ipa::hostadd':}

  file { '/etc/ipa/primary':
    ensure  => 'file',
    content => 'Added by IPA Puppet module. Designates primary master. Do not remove.',
  }

  if $ipa::sudo {
    Ipa::Configsudo <<| |>> {
      name    => $ipa::ipa_server_fqdn,
      os      => "${::osfamily}${::lsbmajdistrelease}",
      require => Ipa::Serverinstall[$ipa::ipa_server_fqdn]
    }
  }

  if $ipa::configure_automount {
    # if $ipa::install_autofs {
    #   realize Service['autofs']
    #   realize Package['autofs']
    # }

    Ipa::Configautomount <<| |>> {
      name    => $ipa::ipa_server_fqdn,
      os      => $::osfamily,
      notify  => Service['autofs'],
      require => Ipa::Serverinstall[$ipa::ipa_server_fqdn],
    }
  }

  realize Package[$ipa::ipa_server_package_name]

  # if $ipa::install_sssd {
  #   realize Package[$ipa::sssd_package_name]
  #   realize Service['sssd']
  # }

  if $ipa::install_kstart {
    realize Package[$ipa::kstart_package_name]
    # TODO: Why??
    cron { 'k5start_root':
      command => '/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_0 > /dev/null 2>&1',
      user    => 'root',
      minute  => '*/1',
      require => Package[$ipa::kstart_package_name],
    }
  }

  # if $ipa::configure_dns_server {
  #   $dnsopt = '--setup-dns'
  #
  #   if size($ipa::forwarders) > 0 {
  #     $forwarderopts = join(prefix($ipa::forwarders, '--forwarder '), ' ')
  #   }
  #   else {
  #     $forwarderopts = '--no-forwarders'
  #   }
  #
  #   realize Package['bind-dyndb-ldap']
  #   realize Package['ipa-server-dns']
  # }
  # else {
  #   $dnsopt = ''
  #   $forwarderopts = ''
  # }

  # $ip_addressopt = $ipa::enable_ip_address ? {
  #   true => "--ip-address ${ipa::ip_address}",
  #   default => '',
  # }
  #
  # $hostopt = $ipa::enable_hostname ? {
  #   true    => "--hostname=${ipa::ipa_server_fqdn}",
  #   default => '',
  # }
  #
  # $ntpopt = $ipa::configure_ntp ? {
  #   false   => '--no-ntp',
  #   default => '',
  # }
  #
  # $extcaopt = $ipa::use_external_ca ? {
  #   true    => '--external-ca',
  #   default => '',
  # }
  #
  # $final_idstart = $ipa::idstart ? {
  #   false => fqdn_rand('10737') + 10000,
  #   default => $ipa::idstart,
  # }

  # ipa::serverinstall { $::fqdn:
  #   realm         => $ipa::master::realm,
  #   domain        => $ipa::master::domain,
  #   adminpw       => $ipa::master::adminpw,
  #   dspw          => $ipa::master::dspw,
  #   dnsopt        => $ipa::master::dnsopt,
  #   ip_addressopt => $ipa::master::ip_addressopt,
  #   forwarderopts => $ipa::master::forwarderopts,
  #   ntpopt        => $ipa::master::ntpopt,
  #   extcaopt      => $ipa::master::extcaopt,
  #   idstart       => $ipa::master::generated_idstart,
  #   require       => Package[$ipa::master::svrpkg],
  #   hostopt       => $ipa::master::hostopt
  # }
  #
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

#   if $ipa::master::sudo {
#     @@ipa::configsudo { $::fqdn:
#       masterfqdn => $::fqdn,
#       domain     => $ipa::master::domain,
#       adminpw    => $ipa::master::adminpw,
#       sudopw     => $ipa::master::sudopw
#     }
#   }
#
#   if $ipa::master::automount {
#     @@ipa::configautomount { $::fqdn:
#       masterfqdn => $::fqdn,
#       os         => $::osfamily,
#       domain     => $ipa::master::domain,
#       realm      => $ipa::master::realm
#     }
#   }
#
#   if $ipa::master::loadbalance {
#     ipa::loadbalanceconf { "master-${::fqdn}":
#       domain     => $ipa::master::domain,
#       ipaservers => $ipa::master::ipaservers,
#       mkhomedir  => $ipa::master::mkhomedir,
#       require    => Ipa::Serverinstall[$::fqdn]
#     }
#   }
}
