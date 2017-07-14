#
class ipa::install {

  if $ipa::install_epel {
    ensure_resource(
      'package',
      'epel-release',
      {'ensure' => 'present'},
    )
  }

  if $ipa::manage_host_entry {
    host { $ipa::ipa_server_fqdn:
      ip => $ipa::ip_address,
    }
  }

  # Note: sssd.conf handled by ipa-server-install.
  if $ipa::install_sssd {
    contain 'ipa::install::sssd'
  }

  if $ipa::install_autofs {
    contain 'ipa::install::autofs'
  }

  if $ipa::install_ldaputils {
    package { $ipa::ldaputils_package_name:
      ensure => present,
    }
  }

  if $ipa::install_sssdtools {
    package { $ipa::sssdtools_package_name:
      ensure => present,
    }
  }

  if $ipa::configure_dns_server {
    $dns_packages = [
      'ipa-server-dns',
      'bind-dyndb-ldap',
      'ipa-server-dns',
    ]
    package{$dns_packages:
      ensure => present,
    }
  }

  if $ipa::install_ipa_server {
    contain 'ipa::install::server'
  }

  # if $ipa::install_ipa_client {
  #   contain 'ipa::install::client'
  # }

}