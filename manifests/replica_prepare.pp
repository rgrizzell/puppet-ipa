class ipa::replica_prepare {

  Cron['k5start_root']
  -> Exec["replicaprepare-${ipa::ipa_server_fqdn}"]
  ~> Exec["replica-info-scp-${ipa::ipa_server_fqdn}"]
  ~> Ipa::Hostdelete[$ipa::ipa_server_fqdn]

  $gpg_file_name = "/var/lib/ipa/replica-info-${ipa::ipa_server_fqdn}.gpg"

  realize Cron['k5start_root']

  $replica_prepare_cmd = shellquote('/usr/sbin/ipa-replica-prepare',"--password=${ipa::directory_services_password}")
  $replica_manage_cmd = shellquote('/usr/sbin/ipa-replica-manage',"--password=${ipa::directory_services_password}")

  exec { "replicaprepare-${ipa::ipa_server_fqdn}":
    command => "${replica_prepare_cmd} ${ipa::ipa_server_fqdn}",
    unless  => "${replica_manage_cmd} list | /bin/grep ${ipa::ipa_server_fqdn} >/dev/null 2>&1",
    timeout => '0',
  }

  $replica_info_scp_cmd = shellquote(
    '/usr/bin/scp',
    '-q',
    '-o',
    'StrictHostKeyChecking=no',
    '-o',
    'GSSAPIAuthentication=yes',
    '-o',
    'ConnectTimeout=5',
    '-o',
    'ServerAliveInterval=2',
    $gpg_file_name,
    "root@${ipa::ipa_server_fqdn}:${gpg_file_name}",
  )
  exec { "replica-info-scp-${ipa::ipa_server_fqdn}":
    command     => $replica_info_scp_cmd,
    refreshonly => true,
    tries       => '60',
    try_sleep   => '60',
  }

  class {'ipa::host_delete':}

}
