# configures port and redirect overrides for the IPA server web UI.
class ipa::config::webui {

  if $ipa::webui_additional_http_port {
    file_line { 'webui_additional_http_port':
      ensure => present,
      path   => '/etc/httpd/conf/httpd.conf',
      line   => "Listen ${ipa::webui_additional_http_port}",
      after  => 'Listen\ 80$',
      notify => Service['httpd'],
    }
  }

  if $ipa::webui_additional_https_port {
    # modify /etc/httpd/conf.d/nss.conf
    ## look for "Listen 443"
    ## add "Listen ${ipa::webui_custom_https_port}"
    file_line{'webui_additional_https_port_listener':
      ensure => present,
      path   => '/etc/httpd/conf.d/nss.conf',
      line   => "Listen ${ipa::webui_additional_https_port}",
      after  => 'Listen\ 443',
      notify => Service['httpd'],
    }

    # find "<VirtualHost _default_:443>"
    ## mod to "<VirtualHost _default_:443 _default_:${ipa::webui_custom_https_port}>"
    file_line{'webui_additional_https_port_virtualhost':
      ensure => present,
      path   => '/etc/httpd/conf.d/nss.conf',
      match  => "<VirtualHost _default_",
      line   => "<VirtualHost _default_:443 _default_:${ipa::webui_additional_https_port}>",
      notify => Service['httpd'],
    }

    # modify /etc/httpd/conf/httpd.conf
    ## find "Listen 80"
    ## add "Listen ${ipa::webui_custom_http_port}"

    # modify /etc/httpd/conf.d/ipa-rewrite.conf
    # -- might just need to use a template :(
  }

}