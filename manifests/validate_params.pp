# Validates input configs from init.pp.
class easy_ipa::validate_params {

  if $easy_ipa::manage_host_entry {
    if $easy_ipa::ipa_server_fqdn == '' {
      fail('When using the parameter manage_host_entry, the parameter ipa_server_fqdn is mandatory.')
    }
    if $easy_ipa::ip_address  == '' {
      fail('When using the parameter manage_host_entry, the parameter ip_address is mandatory.')
    }
  }

  # if $easy_ipa::idstart {
    # validate_legacy(
    #   Optional[Integer],
    #   'validate_re',
    #   $easy_ipa::idstart,
    #   '^\d+$',   # all digits
    # )

  if $easy_ipa::idstart < 10000 {
    fail('Parameter "idstart" must be an integer greater than 10000.')
  }
  # }

  if ! is_domain_name($easy_ipa::domain) {
    fail('Parameter "domain" is not a valid domain name.')
  }

  if ! is_domain_name($easy_ipa::final_realm) {
    fail('Parameter "realm" is not a valid domain name.')
  }

  if $easy_ipa::install_ipa_server {
    validate_legacy(
      Optional[String],
      'validate_re',
      $easy_ipa::admin_password,
      '.{8,}',   # At least 8 characters
    )

    validate_legacy(
      Optional[String],
      'validate_re',
      $easy_ipa::directory_services_password,
      '.{8,}',   # At least 8 characters
    )
  }

  # TODO: validate ipa_master_fqdn is a hostname.
  if $easy_ipa::ipa_role == 'replica' {
    if $easy_ipa::ipa_master_fqdn == ''{
      fail('When creating a replica the parameter named ipa_master_fqdn cannot be empty.')
    }
  }

  # TODO: if $ipa_role == 'replica' then make sure hostname is in $replica_fqdn_list
  # TODO: make $final_replica_fqdn_list

  # TODO: if $webui_proxy_https_port then it can't be 443.
}