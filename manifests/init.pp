# Class: vision_server
# ===========================
#
# Parameters
# ----------
#
# Examples
# --------
#
# @example
# contain ::vision_server
#

class vision_server {

  # Hint: vision_base is contained in the role
  contain vision_server::exim
  contain vision_server::mysql
  contain vision_server::hashicorp::consul
  contain vision_server::hashicorp::nomad

}
