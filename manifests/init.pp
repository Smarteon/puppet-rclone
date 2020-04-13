# @summary Download and install Rclone
#
# Install rclone binary and man page
#
# @example
#   include rclone
#
# @param ensure
#   installed version, can be 'latest', 'absent' or valid version string
#
class rclone(
  Pattern[/absent/, /latest/, /\d+\.\d+\.\d+/] $ensure = 'latest',
) {

  $install_dir = '/opt/rclone'
  $binary = '/usr/bin/rclone'
  $man_page_dir = '/usr/local/share/man/man1'
  $man_page = "${man_page_dir}/rclone.1"

  case $ensure {
    'absent': { contain rclone::uninstall }
    default: { contain rclone::install }
  }

  exec { 'rclone mandb':
    command     => 'mandb',
    path        => '/usr/bin',
    refreshonly => true,
  }
}
