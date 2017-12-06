#
# == Class: easy_ipa::packetfilter::server
#
# Install packet filtering rules for FreeIPA
#
class easy_ipa::packetfilter::server
(
  String $allow_address_ipv4 = '127.0.0.1',
  String $allow_address_ipv6 = '::1'
)
{

  # A hash containing the data for packet filtering rules
  $services = { 'dns'             => { 'tcp' => 53,  'udp' => 53  },
                'http'            => { 'tcp' => 80                },
                'https'           => { 'tcp' => 443               },
                'kerberos'        => { 'tcp' => 88,  'udp' => 88  },
                'kerberos passwd' => { 'tcp' => 464, 'udp' => 464 },
                'ldaps'           => { 'tcp' => 636               },
                'ntp'             => { 'udp' => 123               },
  }

  Firewall {
    chain    => 'INPUT',
    action   => 'accept',
  }

  $services.each |$service| {
    $service[1].each |$rule| {
      $service_name = $service[0]
      $protocol = $rule[0]
      $port = $rule[1]

      @firewall { "008 ipv4 accept ${service_name} ${protocol}":
        provider => 'iptables',
        proto    => $proto,
        source   => $allow_address_ipv4,
        tag      => 'default',
      }
      @firewall { "008 ipv6 accept ${service_name} ${protocol}":
        provider => 'ip6tables',
        proto    => $proto,
        source   => $allow_address_ipv6,
        tag      => 'default',
      }
    }
  }
}
