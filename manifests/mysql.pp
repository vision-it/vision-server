# Class: vision_server::mysql
# ===========================
#
# Manage MariaDB Installation
#
# Parameters
# ----------
#
# @param root_password Password for root user
# @param backup_password Password for backup creation user
# @param package_name Server package name
# @param ipaddress Bind Address
#
# Examples
# --------
#
# @example
# contain ::vision_mysql::server
#

class vision_server::mysql (

  Sensitive[String] $root_password,
  Sensitive[String] $backup_password = Sensitive(fqdn_rand_string(32)),
  String $package_name = 'mariadb-server',
  String $ipaddress = $::ipaddress,
  # These variables are just for the CI pipeline
  Boolean $service_manage  = true,
  Boolean $service_enabled = true,

) {

  # Default options, the rest gets merged with this Hash
  $override_options = {
    'mysqld' => {
      'bind-address' => '127.0.0.1',
      'sql-mode'     => 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION',
    }
  }

  class { '::mysql::server':
    package_name            => $package_name,
    root_password           => $root_password.unwrap,
    remove_default_accounts => true,
    restart                 => true,
    service_manage          => $service_manage,
    service_enabled         => $service_enabled,
    override_options        => $override_options,
  }

  class { '::mysql::server::backup':
    backupuser        => 'backup',
    backuppassword    => $backup_password.unwrap,
    backupdir         => '/root/sql-backup',
    file_per_database => true,
    maxallowedpacket  => '16M',
  }

  # Small helper script to create databases and users
  file { '/root/init-db.sh':
    ensure  => present,
    mode    => '0740',
    content => file('vision_server/init-db.sh'),
  }

}
