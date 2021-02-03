# Class: vision_server::hashicorp::consul
# ===========================
#
# Parameters
# ----------
#
# @param advertise_addr Address to bind to.
# @param services Consul Services to create.
#
# Examples
# --------
#
# @example
# contain ::vision_server::hashicorp::consul
#

class vision_server::hashicorp::consul (

  String $advertise_addr = $::ipaddress,
  Optional[Hash] $services = {},

) {

  contain vision_server::hashicorp::repo
  contain vision_server::hashicorp::dnsmasq

  package { 'consul':
    ensure  => present,
    require => Class['vision_server::hashicorp::repo'],
  }

  file { '/etc/consul.d/consul.hcl':
    ensure  => present,
    owner   => 'consul',
    group   => 'consul',
    mode    => '0640',
    content => template('vision_server/hashicorp/consul.hcl.erb'),
    notify  => Service['consul'],
    require => Package['consul'],
  }

  service { 'consul':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => Package['consul'],
  }

  $service_defaults = {
    notify  => Service['consul'],
    require => Package['consul'],
  }

  create_resources('vision_server::hashicorp::consul_service', $services, $service_defaults)
}
