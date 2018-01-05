#
# == Class: easy_ipa::params
#
# Traditionally this file would be used to abstract away operating system 
# differences. Right now the main purpose is to prevent easy_ipa classes from
# causing havoc (e.g. partial configurations) on unsupported operating systems
# by failing early rather than later.
#
class easy_ipa::params {

  case $facts['os']['family'] {
    'RedHat': {
      case $facts['os']['release']['major'] {
        /(7)/:   { }
        default: { fail('ERROR: unsupported operating system') }
      }
    }
    'Debian': {
      case $facts['os']['distro']['codename'] {
        /(trusty|xenial|stretch)/: { }
        default:                   { fail('ERROR: unsupported operating system') }
      }
    }
    default: {
      fail('ERROR: unsupported operating system!')
    }
  }
}
