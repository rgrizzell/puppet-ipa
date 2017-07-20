# configures port and redirect overrides for the IPA server web UI.
class ipa::config::webui {

  if $ipa::webui_enable_proxy {
    #ref: https://www.redhat.com/archives/freeipa-users/2016-June/msg00128.html
    $proxy_server_internal_fqdn = $ipa::ipa_server_fqdn
    $proxy_server_external_fqdn = $ipa::webui_proxy_external_fqdn
    $proxy_https_port = $ipa::webui_proxy_https_port

    $proxy_internal_uri = "https://${proxy_server_internal_fqdn}"
    $proxy_external_uri = "https://${proxy_server_external_fqdn}:${proxy_https_port}"
    $proxy_server_name = "https://${ipa::ipa_server_fqdn}:${proxy_https_port}"
    $proxy_referrer_regex = regsubst(
      $proxy_external_uri,
      '\.',
      '\.',
      'G',
    )

    file_line { 'webui_additional_https_port_listener':
      ensure => present,
      path   => '/etc/httpd/conf.d/nss.conf',
      line   => "Listen ${proxy_https_port}",
      after  => 'Listen\ 443',
      notify => Service['httpd'],
    }

    file { '/etc/httpd/conf.d/ipa-rewrite.conf':
      ensure  => present,
      replace => true,
      content => template('ipa/ipa-rewrite.conf.erb'),
      notify  => Service['httpd'],
    }

    file { '/etc/httpd/conf.d/ipa-webui-proxy.conf':
      ensure  => present,
      replace => true,
      content => template('ipa/ipa-webui-proxy.conf.erb'),
      notify  => Service['httpd'],
    }

  }

  if $ipa::webui_disable_kerberos {
    $lines_to_comment = [
      'AuthType GSSAPI',
      'AuthName "Kerberos Login"',
      'GssapiCredStore keytab:/etc/httpd/conf/ipa.keytab',
      'GssapiCredStore client_keytab:/etc/httpd/conf/ipa.keytab',
      'GssapiDelegCcacheDir /var/run/httpd/ipa/clientcaches',
      'GssapiDelegCcacheUnique On',
      'GssapiUseS4U2Proxy on',
      'GssapiAllowedMech krb5',
      'Require valid-user',
      'ErrorDocument 401 /ipa/errors/unauthorized.html',
    ]

    $lines_to_comment.each | $index, $cur_line | {
      $match_str = regsubst(
        $cur_line,
        ' ',
        '\ ',
        'G',
      )
      file_line{"disable_kerberos_${index}":
        ensure => present,
        path   => '/etc/httpd/conf.d/ipa.conf',
        line   => "# ${cur_line}",
        match  => $match_str,
        notify => Service['httpd'],
      }
    }

  }

}