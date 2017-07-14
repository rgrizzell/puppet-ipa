# == Class: ipa
#
# Manages IPA masters, replicas and clients.
#
# === Parameters
#
#
#  ipa_role
#    Should be set to 'master', 'replicate', or 'client'.
#
#  $master = false - Configures a server to be an IPA master LDAP/Kerberos node.
#  $replica = false - Configures a server to be an IPA replica LDAP/Kerberos node.
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
class ipa (
  $admin_password,
  $directory_services_password,
  $domain,
  $ipa_role,
  $realm,
  $autofs_package_name     = 'autofs',
  $cleanup                 = false,
  $client_description      = undef,
  $configure_automount     = false,
  $configure_dns_server    = false,
  $configure_ntp           = false,
  $custom_dns_forwarders   = [],
  $debiansudopkg           = true,
  $dirsrv_pin              = undef,
  $dirsrv_pkcs12           = undef,
  $enable_firewall         = true,
  $enable_hostname         = true,
  $enable_ip_address       = false,
  $extcacert               = undef,
  $extcertpath             = undef,
  $extcert                 = undef,
  $external_ca_server_file = undef,
  $fixedprimary            = false,
  $http_pkcs12             = undef,
  $http_pin                = undef,
  $idstart                 = undef,
  $install_autofs          = false,
  $install_kstart          = true,
  $install_ldaputils       = true,
  $install_sssdtools       = true,
  $ipa_client_package_name = $::osfamily ? {
    'Debian' => 'freeipa-client',
    default  => 'ipa-client',
  },
  $ipa_server_package_name = 'ipa-server',
  $ipaservers              = [],
  $install_ipa_client      = false,
  $install_ipa_server      = false,
  $install_sssd            = true,
  $ip_address              = undef,
  $ipa_server_fqdn         = $::fqdn,
  $kstart_package_name     = 'kstart',
  $ldaputils_package_name  = $::osfamily ? {
    'Debian' => 'ldap-utils',
    default  => 'openldap-clients',
  },
  $loadbalance             = false,
  $locality                = '',
  $location                = '',
  $manage_host_entry       = false,
  $mkhomedir               = false,
  $one_time_password       = undef,
  $selfsign                = false,
  $sssd_package_name       = 'sssd-common',
  $sssdtools_package_name  = 'sssd-tools',
  $subject                 = undef,
  $sudo                    = false,
  $sudopw                  = undef,
  $use_external_ca         = false,
) {

  class {'::ipa::validate_params':}
  -> class {'::ipa::install':}



}
