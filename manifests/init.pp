# == Class: ipa
#
# Manages IPA masters, replicas and clients.
#
# === Parameters
#
#
#  ipa_role
#    Should be set to 'master', 'replica', or 'client'. Master and replica is a bit of a misnomer, since replicas
#    become masters after they are installed. Use 'master' for the first server creating the IPA domain.
#
#  $client = false - Configures a server to be an IPA client.
#  $cleanup = false - Removes IPA specific packages.
#  $domain = undef - Defines the LDAP domain.
#  $realm = undef - Defines the Kerberos realm.
#  $adminpw = undef - Defines the IPA administrative user password.
#  $dspw = undef - Defines the IPA directory services password.
#  $otp = undef - Defines an IPA client one-time-password.
#  $dns = false - Controls the option to configure a DNS zone with the IPA master setup.
#  $ip_address = undef -  Specifies the IP address of the server.
#  $fixedprimary = false - Configure sssd to use a fixed server as the primary IPA server.
#  $forwarders = [] - Defines an array of DNS forwarders to use when DNS is setup. An empty list will use the Root Nameservers.
#  $extca = false - Controls the option to configure an external CA.
#  $extcertpath = undef - Defines a file path to the external certificate file. Somewhere under /root is recommended.
#  $extcert = undef - The X.509 certificate in base64 encoded format.
#  $extcacertpath = undef - Defines a file path to the external CA certificate file. Somewhere under /root is recommended.
#  $extcacert = undef - The X.509 CA certificate in base64 encoded format.
#  $dirsrv_pkcs12 = undef - PKCS#12 file containing the Directory Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa
#  $http_pkcs12 = undef - The PKCS#12 file containing the Apache Server SSL Certificate, also corresponds to the Puppet fileserver path under fileserverconfig for $confdir/files/ipa
#  $dirsrv_pin = undef - The password of the Directory Server PKCS#12 file.
#  $http_pin = undef - The password of the Apache Server PKCS#12 file.
#  $subject = undef - The certificate subject base.
#  $selfsign = false - Configure a self-signed CA instance for issuing server certificates instead of using dogtag for certificates.
#  $loadbalance = false - Controls the option to include any additional hostnames to be used in a load balanced IPA client configuration.
#  $ipaservers = [] - Defines an array of additional hostnames to be used in a load balanced IPA client configuration.
#  $mkhomedir = false - Controls the option to create user home directories on first login.
#  $ntp = false - Controls the option to configure NTP on a client.
#  $kstart = true - Controls the installation of kstart.
#  $desc = '' - Controls the description entry of an IPA client.
#  $locality = '' - Controls the locality entry of an IPA client.
#  $location = '' - Controls the location entry of an IPA client.
#  $sssdtools = true - Controls the installation of the SSSD tools package.
#  $sssdtoolspkg = 'sssd-tools' - SSSD tools package.
#  $sssd = true - Controls the option to start the SSSD service.
#  $sudo = false - Controls the option to configure sudo in LDAP.
#  $sudopw = undef - Defines the sudo user bind password.
#  $debiansudopkg = true - Controls the installation of the Debian sudo-ldap package.
#  $automount = false - Controls the option to configure automounter maps in LDAP.
#  $autofs = false - Controls the option to start the autofs service and install the autofs package.
#  $svrpkg = 'ipa-server' - IPA server package.
#  $clntpkg = 'ipa-client' - IPA client package.
#  $ldaputils = true - Controls the instalation of the LDAP utilities package.
#  $ldaputilspkg = 'openldap-clients' - LDAP utilities package.
#  $enable_firewall = true - Install and Configure iptables ? this is not desired for docker container 
#  $enable_hostname = true - Configure hostname during instalation? this is not desired for docker container
#
# === Variables
#
#
# === Examples
#
#
# === Authors
#
#
# === Copyright
#
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
  #$cleanup                            = false,
  $client_description                 = undef,
  #$configure_automount                = false,
  $configure_dns_server               = true,
  $configure_ntp                      = true,
  $custom_dns_forwarders              = [],
  #$debiansudopkg                      = true,
  #$dirsrv_pin                         = undef,
  #$dirsrv_pkcs12                      = undef,
  $domain_join_principal              = undef,
  $domain_join_password               = undef,
  $enable_firewall                    = true,
  $enable_hostname                    = true,
  $enable_ip_address                  = false,
  #$extcacert                          = undef,
  #$extcertpath                        = undef,
  #$extcert                            = undef,
  #$external_ca_server_file            = undef,
  $fixed_primary                      = false,
  #$http_pkcs12                        = undef,
  #$http_pin                           = undef,
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
  #$ipaservers                         = [],
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
  #$loadbalance                        = false,
  #$locality                           = '',
  #$location                           = '',
  $ipa_master_fqdn                    = undef,
  $manage_host_entry                  = false,
  $mkhomedir                          = true,
  $no_ui_redirect                     = false,
  #$one_time_password                  = undef,
  $realm                              = undef,
  #$replica_fqdn_list                  = [],
  #$selfsign                           = false,
  $sssd_package_name                  = 'sssd-common',
  $sssdtools_package_name             = 'sssd-tools',
  #$subject                            = undef,
  #$sudo                               = false,
  #$sudopw                             = undef,
  #$use_external_ca                    = false,
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
    $final_domain_join_principal = 'admin'  #"admin@${final_realm}"
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
