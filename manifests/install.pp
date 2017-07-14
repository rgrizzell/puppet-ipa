#
class ipa::install {

  if $ipa::manage_host_entry {
    host { $ipa::ipa_server_fqdn:
      ip => $ipa::ip_address,
    }
  }

  # TODO: sssd.conf
  # if $ipa::install_sssd {
  #   contain 'ipa::helper_packages::sssd'
  # }

  if $ipa::install_autofs {
    contain 'ipa::helper_packages::autofs'
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