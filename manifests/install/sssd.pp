#
class ipa::install::sssd {

  package { $ipa::sssd_package_name:
    ensure => present,
  }

}