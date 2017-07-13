class ipa::host_delete {

  exec { "hostdelete-${ipa::ipa_server_fqdn}":
    command     => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-del ${ipa::ipa_server_fqdn}\'",
    refreshonly => true,
    onlyif      => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-show ${ipa::ipa_server_fqdn} >/dev/null 2>&1\'",
  }
}
