class ipa::server () inherits ::ipa {

  if $::osfamily != 'RedHat' and $::osfamily != 'Centos' {
    fail("This module cannot configure IPA server on the ${::operatingsystem} operating system.")
  }

  @package { $ipa::ipa_server_package_name:
    ensure => present,
  }

  if $ipa::install_ldaputils {
    @package { $ipa::ldaputils_package_name:
      ensure => present,
    }
  }

  if $ipa::install_sssdtools {
    @package { $ipa::sssdtools_package_name:
      ensure => present,
    }
  }

  if $ipa::install_kstart {
    @package { $ipa::kstart_package_name:
      ensure => present,
    }
  }

  @service { 'ipa':
    ensure  => 'running',
    enable  => true,
    require => Package[$ipa::ipa_server_package_name],
  }

  if $ipa::configure_dns_server {
    $dns_packages = [
      'ipa-server-dns',
      'bind-dyndb-ldap',
      'ipa-server-dns',
    ]
    @package{$dns_packages:
      ensure => present,
    }
  }

  # TODO: Should be 'allow_master' as in 'if no other masters, make this on the master.
  if $ipa::ipa_role == 'master' {
    include 'ipa::server::master'

    if ! $ipa::admin_password {
      fail('Required parameter "adminpw" missing')
    }
    if ! $ipa::directory_services_password {
      fail('Required parameter "dspw" missing')
    }
  } elsif $ipa::ipa_role == 'replica' {
    include 'ipa::server::replica'
  }

}