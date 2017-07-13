#
class ipa::helper_packages::autofs {
  package { $ipa::autofs_package_name:
    ensure => present,
  }

  service { 'autofs':
    ensure => 'running',
    enable => true,
  }
}