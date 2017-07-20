# Validates input configs from init.pp.
class ipa::validate_params {

  if $ipa::manage_host_entry {
    if !$ipa::ipa_server_fqdn {
      fail('When using the parameter manage_host_entry, the parameter ipa_server_fqdn is mandatory.')
    }
    if !$ipa::ip_address {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }

  if $ipa::idstart {
    validate_legacy(
      Optional[String],
      'validate_re',
      $ipa::idstart,
      '^\d+$',   # all digits
    )

    if $ipa::idstart < 10000 {
      fail('Parameter "idstart" must be an integer greater than 10000.')
    }
  }

  if ! is_domain_name($ipa::domain) {
    fail('Parameter "domain" is not a valid domain name.')
  }

  if ! is_domain_name($ipa::final_realm) {
    fail('Parameter "realm" is not a valid domain name.')
  }

  if $ipa::install_ipa_server {
    validate_legacy(
      Optional[String],
      'validate_re',
      $ipa::admin_password,
      '.{8,}',   # At least 8 characters
    )

    validate_legacy(
      Optional[String],
      'validate_re',
      $ipa::directory_services_password,
      '.{8,}',   # At least 8 characters
    )
  }

  # TODO: validate ipa_master_fqdn is a hostname.
  if $ipa::ipa_role == 'replica' {
    if !$ipa::ipa_master_fqdn {
      fail('When creating a replica the parameter named ipa_master_fqdn cannot be empty.')
    }
  }

  # TODO: if $ipa_role == 'replica' then make sure hostname is in $replica_fqdn_list
  # TODO: make $final_replica_fqdn_list

  # TODO: if $webui_proxy_https_port then it can't be 443.
}