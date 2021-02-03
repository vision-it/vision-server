# Class: vision_server::hashicorp::nomad
# ===========================
#
# Parameters
# ----------
#
# @param advertise_addr Address to bind to.
#
# Examples
# --------
#
# @example
# contain ::vision_hashicorp::nomad::server
#

class vision_server::hashicorp::nomad (

  String $advertise_addr = $::ipaddress,

) {

  contain vision_server::hashicorp::repo

  package { 'nomad':
    ensure  => present,
    require => Class['vision_server::hashicorp::repo'],
  }

  file { '/etc/nomad.d/nomad.hcl':
    ensure  => present,
    owner   => 'nomad',
    group   => 'nomad',
    mode    => '0640',
    content => template('vision_server/hashicorp/nomad.hcl.erb'),
    require => Package['nomad'],
    notify  => Service['nomad'],
  }

  file { '/etc/nomad.d/anonymous.policy':
    ensure  => present,
    owner   => 'nomad',
    group   => 'nomad',
    mode    => '0640',
    content => file('vision_server/hashicorp/nomad_anonymous.policy'),
    require => Package['nomad'],
  }

  file { '/etc/nomad.d/default.policy':
    ensure  => present,
    owner   => 'nomad',
    group   => 'nomad',
    mode    => '0640',
    content => file('vision_server/hashicorp/nomad_default.policy'),
    require => Package['nomad'],
  }

  # Deploy customized Service Unit, for Consul and DNS adjustments.
  file { '/etc/systemd/system/nomad.service':
    ensure  => present,
    mode    => '0644',
    content => file('vision_server/hashicorp/nomad.service'),
    require => Package['nomad'],
    notify  => Service['nomad'],
  }

  service { 'nomad':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    require    => [
      Package['nomad'],
      File['/etc/systemd/system/nomad.service'],
    ],
  }

}
