# == Class: ipa
#
# Manages IPA masters, replicas and clients.
#
# Parameters
# ----------
# `domain`
#      (string) The name of the IPA domain to create or join.
# `ipa_role`
#      (string) What role the node will be. Options are 'master', 'replica', and 'client'.
#
# `admin_password`
#      (string) Password which will be assigned to the IPA account named 'admin'.
#
# `directory_services_password`
#      (string) Password which will be passed into the ipa setup's parameter named "--ds-password".
#
# `autofs_package_name`
#      (string) Name of the autofs package to install if enabled.
#
# `configure_dns_server`
#      (boolean) If true, then the parameter '--setup-dns' is passed to the IPA server installer.
#                Also, triggers the install of the required dns server packages.
#
# `configure_ntp`
#      (boolean) If false, then the parameter '--no-ntp' is passed to the IPA server installer.
#
# `custom_dns_forwarders`
#      (array[string]) Each element in this array is prefixed with '--forwarder '
#                      and passed to the IPA server installer.
#
# `domain_join_principal`
#      (string) The principal (usually username) used to join a client or replica to the IPA domain.
#
# `domain_join_password`
#      (string) The password for the domain_join_principal.
#
# `enable_hostname`
#      (boolean) If true, then the parameter '--hostname' is populated with the parameter 'ipa_server_fqdn'
#                and passed to the IPA installer.
#
# `enable_ip_address`
#      (boolean) If true, then the parameter '--ip-address' is populated with the parameter 'ip_address'
#                and passed to the IPA installer.
#
# `fixed_primary`
#      (boolean) If true, then the parameter '--fixed-primary' is passed to the IPA installer.
#
# `idstart`
#      (integer) From the IPA man pages: "The starting user and group id number".
#
# `install_autofs`
#      (boolean) If true, then the autofs packages are installed.
# `install_epel`
#      (boolean) If true, then the epel repo is installed. The epel repo is usually required for sssd packages.
#
# `install_kstart`
#      (boolean) If true, then the kstart packages are installed.
#
# `install_ldaputils`
#      (boolean) If true, then the ldaputils packages are installed.
#
# `install_sssdtools`
#      (boolean) If true, then the sssdtools packages are installed.
#
# `ipa_client_package_name`
#      (string) Name of the IPA client package.
#
# `ipa_server_package_name`
#      (string) Name of the IPA server package.
#
# `install_ipa_client`
#      (boolean) If true, then the IPA client packages are installed if the parameter 'ipa_role' is set to 'client'.
#
# `install_ipa_server`
#      (boolean) If true, then the IPA server packages are installed if the parameter 'ipa_role' is not set to 'client'.
#
# `install_sssd`
#      (boolean) If true, then the sssd packages are installed.
#
# `ip_address`
#      (string) IP address to pass to the IPA installer.
#
# `ipa_server_fqdn`
#      (string) Actual fqdn of the IPA server or client.
#
# `kstart_package_name`
#      (string) Name of the kstart package.
#
# `ldaputils_package_name`
#      (string) Name of the ldaputils package.
#
# `ipa_master_fqdn`
#      (string) FQDN of the server to use for a client or replica domain join.
#
# `manage_host_entry`
#      (boolean) If true, then a host entry is created using the parameters 'ipa_server_fqdn' and 'ip_address'.
#
# `mkhomedir`
#      (boolean) If true, then the parameter '--mkhomedir' is passed to the IPA client installer.
#
# `no_ui_redirect`
#      (boolean) If true, then the parameter '--no-ui-redirect' is passed to the IPA server installer.
#
# `realm`
#      (string) The name of the IPA realm to create or join.
#
# `sssd_package_name`
#      (string) Name of the sssd package.
#
# `sssdtools_package_name`
#      (string) Name of the sssdtools package.
#
# `webui_disable_kerberos`
#      (boolean) If true, then /etc/httpd/conf.d/ipa.conf is written to exclude kerberos support for
#                incoming requests whose HTTP_HOST variable match the parameter 'webio_proxy_external_fqdn'.
#                This allows the IPA Web UI to work on a proxied port, while allowing IPA client access to
#                function as normal.
#
# `webui_enable_proxy`
#      (boolean) If true, then httpd is configured to act as a reverse proxy for the IPA Web UI. This allows
#                for the Web UI to be accessed from different ports and hostnames than the default.
#
# `webui_force_https`
#      (boolean) If true, then /etc/httpd/conf.d/ipa-rewrite.conf is modified to force all connections to https.
#                This is necessary to allow the WebUI to be accessed behind a reverse proxy when using nonstandard
#                ports.
#
# `webui_proxy_external_fqdn`
#      (string) The public or external FQDN used to access the IPA Web UI behind the reverse proxy.
#
# `webui_proxy_https_port`
#      (integer) The HTTPS port to use for the reverse proxy. Cannot be 443.
#
# TODO: enable local host entry for hostname + ipaddress (for vagrant, for example).
# TODO: exported resource for ipa_master_fqdn.
#
# TODO: ipa localhost redirect is a problem (localhost:8441 -> fqdn).
# TODO: dns updates aren't working
# TODO: allow changing of KrbMethodK5Passwd in /etc/httpd/conf.d/ipa.conf for username/pass
# TODO: allow disable of webui redirect in /etc/httpd/conf.d/ipa-rewrite.conf.

# TODO: ref on https proxy https://www.adelton.com/freeipa/freeipa-behind-proxy-with-different-name
# TODO: another ref on https proxy: https://www.adelton.com/freeipa/freeipa-behind-ssl-proxy
#
# TODO: so, add another httpd conf for :8443, feature flagged, for vagrant Virtualbox that does a rewrite.
# TODO: I think I'm going to need another VM just for the web ui proxy...
#
# TODO: Allow creation of root zone for isolated networks -- https://www.freeipa.org/page/Howto/DNS_in_isolated_networks
#
# TODO: Secure flag removal of login cookie _or_ https:// binding via NSSEngine to :8000.
#
class ipa (
  $domain,
  $ipa_role,
  $admin_password                     = undef,
  $directory_services_password        = undef,
  $autofs_package_name                = 'autofs',
  $configure_dns_server               = true,
  $configure_ntp                      = true,
  $custom_dns_forwarders              = [],
  $domain_join_principal              = undef,
  $domain_join_password               = undef,
  $enable_hostname                    = true,
  $enable_ip_address                  = false,
  $fixed_primary                      = false,
  $idstart                            = undef,
  $install_autofs                     = false,
  $install_epel                       = true,
  $install_kstart                     = true,
  $install_ldaputils                  = true,
  $install_sssdtools                  = true,
  $ipa_client_package_name            = $::osfamily ? {
    'Debian' => 'freeipa-client',
    default  => 'ipa-client',
  },
  $ipa_server_package_name            = 'ipa-server',
  $install_ipa_client                 = false,
  $install_ipa_server                 = false,
  $install_sssd                       = true,
  $ip_address                         = undef,
  $ipa_server_fqdn                    = $::fqdn,
  $kstart_package_name                = 'kstart',
  $ldaputils_package_name             = $::osfamily ? {
    'Debian' => 'ldap-utils',
    default  => 'openldap-clients',
  },
  $ipa_master_fqdn                    = undef,
  $manage_host_entry                  = false,
  $mkhomedir                          = true,
  $no_ui_redirect                     = false,
  $realm                              = undef,
  $sssd_package_name                  = 'sssd-common',
  $sssdtools_package_name             = 'sssd-tools',
  $webui_disable_kerberos             = false,
  $webui_enable_proxy                 = false,
  $webui_force_https                  = false,
  $webui_proxy_external_fqdn          = 'localhost',
  $webui_proxy_https_port             = '8440',
) {

  # TODO: move to params.pp
  if $realm {
    $final_realm = $realm
  } else {
    $final_realm = upcase($domain)
  }

  $master_principals = suffix(
    prefix(
      [$ipa_server_fqdn],
      'host/'
    ),
    "@${final_realm}"
  )

  if $idstart {
    $final_idstart = $idstart
  } else {
    $final_idstart = fqdn_rand('10737') + 10000
  }

  if $domain_join_principal {
    $final_domain_join_principal = $domain_join_principal
  } else {
    $final_domain_join_principal = 'admin'
  }

  if $domain_join_password {
    $final_domain_join_password = $domain_join_password
  } else {
    $final_domain_join_password = $directory_services_password
  }

  if $ipa_role == 'client' {
    $final_configure_dns_server = false
  } else {
    $final_configure_dns_server = $configure_dns_server
  }

  class {'::ipa::validate_params':}
  -> class {'::ipa::install':}

}
