# Define: vision_server::hashicorp::consul_service
# ===========================
#
# Creates a Consul Service
#
# Parameters
# ----------
#
# @param port Port of the Service
# @param address Address of the Service
# @param tags List of Tags for the Service
# @param checks List of checks for the Service
# @param service_name Name of the Service
# @param service_id ID of the Service
#

define vision_server::hashicorp::consul_service (

  Integer $port,
  Optional[String] $address = undef,
  Array $tags = [],
  Array[Hash] $checks = [],
  String $service_name = $title,
  String $service_id = "${::hostname}-${title}",

) {

  file { "/etc/consul.d/service_${title}.json":
    ensure  => present,
    owner   => 'consul',
    group   => 'consul',
    mode    => '0640',
    content => template('vision_server/hashicorp/consul_service.json.erb'),
  }
}
