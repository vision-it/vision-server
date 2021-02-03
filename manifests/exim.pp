# Class: vision_server::exim
# ===========================
#
# Parameters
# ----------
#
# @param smarthost Which mailserver to use
#

class vision_server::exim (

  String $mailserver,
  String $catch_all_email,

) {

  package { 'exim4':
    ensure => present,
  }

  file { '/etc/exim4/conf.d/router/160_exim4-config_vision':
    ensure  => present,
    content => template('vision_server/exim-smarthost.erb'),
    require => Package['exim4'],
    notify  => Service['exim4'],
  }

  file { '/etc/exim4/update-exim4.conf.conf':
    ensure  => present,
    content => template('vision_server/exim-satellite.erb'),
    require => Package['exim4'],
    notify  => Service['exim4'],
  }

  mailalias { 'vision-it':
    ensure    => present,
    name      => root,
    target    => '/etc/aliases',
    recipient => $catch_all_email,
  }

  file { '/etc/mailname':
    ensure  => present,
    require => Package['exim4'],
    content => $::fqdn,
  }

  service { 'exim4':
    ensure  => running,
    require => Package['exim4'],
  }
}
