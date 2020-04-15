# @summary Removes rclone installed by this module
#
# @api private
class rclone::uninstall {

  file { "remove ${rclone::man_page}":
    ensure => absent,
    path   => $rclone::man_page,
    notify => Exec['rclone mandb'],
  }

  file { "remove ${rclone::binary}":
    ensure => absent,
    path   => $rclone::binary,
  }

  file { "remove ${rclone::install_dir}":
    ensure  => absent,
    path    => $rclone::install_dir,
    purge   => true,
    recurse => true,
    force   => true,
  }
}
