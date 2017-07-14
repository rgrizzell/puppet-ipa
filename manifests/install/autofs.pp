#
class ipa::install::autofs {
  package { $ipa::autofs_package_name:
    ensure => present,
  }

  service { 'autofs':
    ensure => 'running',
    enable => true,
  }
}