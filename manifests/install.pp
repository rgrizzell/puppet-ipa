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

  if $ipa::configure_dns_server {
    package{'bind-dyndb-ldap':
      ensure => present,
    }
    package{'ipa-server-dns':
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