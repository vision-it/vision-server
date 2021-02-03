# Class: vision_server::hashicorp::dnsmasq
# ===========================
#
# https://learn.hashicorp.com/tutorials/consul/dns-forwarding
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_server::hashicorp::dnsmasq
#

class vision_server::hashicorp::dnsmasq {

  # DNS Service to ensure other applications can access it via port 53
  package { 'dnsmasq':
    ensure => present,
  }

  # DNS config for Consul
  file { '/etc/dnsmasq.d/10-consul':
    ensure  => present,
    mode    => '0644',
    content => 'server=/consul/127.0.0.1#8600',
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

  file { '/etc/dnsmasq.conf':
    ensure  => present,
    mode    => '0644',
    content => file('vision_server/hashicorp/dnsmasq.conf'),
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

  # It's simpler to just keep the current resolv.conf
  file { '/etc/dhcp/dhclient-enter-hooks.d/keep-resolv':
    ensure  => present,
    mode    => '0755',
    content => file('vision_server/hashicorp/dnsmasq-dhclient.conf'),
  }

  file_line { 'consul_dns':
    path   => '/etc/resolv.conf',
    after  => 'search.*',
    line   => 'nameserver 127.0.0.1',
    notify => Service['dnsmasq'],
  }

  service { 'dnsmasq':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [
      File['/etc/dnsmasq.conf'],
      File['/etc/dnsmasq.d/10-consul'],
    ]
  }

}
