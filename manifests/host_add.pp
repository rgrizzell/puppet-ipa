class ipa::host_add (
  $client_os       = $::lsbdistdescription,
  $client_platform = $::manufacturer,
){

  $timestamp = strftime('%a %b %d %Y %r')
  $client_description = rstrip(
    join(
      [
        'Added by the IPA Puppet module on',
        $timestamp,
        $ipa::client_description,
      ],
      ' '
    )
  )

  exec { "hostadd-${ipa::ipa_server_fqdn}":
    command   => "\
/sbin/runuser \
  -l admin \
  -c \'\
    /usr/bin/ipa host-add ${ipa::ipa_server_fqdn} \
    --force --locality=\"${ipa::locality}\" \
    --location=\"${ipa::location}\" \
    --desc=\"${client_description}\" \
    --platform=\"${client_platform}\" \
    --os=\"${client_os}\" \
    --password=${ipa::one_time_password}\'",
    unless    => "/sbin/runuser -l admin -c \'/usr/bin/ipa host-show ${ipa::ipa_server_fqdn} >/dev/null 2>&1\'",
    tries     => '60',
    try_sleep => '60',
    require   => Ipa::Serverinstall[$ipa::ipa_server_fqdn],
  }
}
