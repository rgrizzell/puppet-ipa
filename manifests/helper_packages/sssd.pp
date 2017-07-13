#
class ipa::helper_packages::sssd {

  package { $ipa::sssd_package_name:
    ensure => present,
  }

  service { 'sssd':
    ensure  => 'running',
    enable  => true,
    require => Package[$ipa::sssd_package_name],
  }

}