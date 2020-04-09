# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rclone
class rclone(
  String $version = 'current',
) {

  $os = $facts['os']['family'] ? {
    /(Debian|Ubuntu)/ => 'linux',
    default           => 'UnknownOS',
  }

  $architecture = $facts['os']['architecture'] ? {
    /arm.*/          => 'arm',
    /(amd64|x86_64)/ => 'amd64',
  }

  $download_path = '/tmp/rclone.zip'
  $install_dir = '/opt/rclone'
  $instance = "rclone-v${version}-${os}-${architecture}"
  $instance_binary = "${install_dir}/${instance}/rclone"
  $instance_man_page = "${install_dir}/${instance}/rclone.1"

  $binary = '/usr/bin/rclone'
  $man_page_dir = '/usr/local/share/man/man1'
  $man_page = "${man_page_dir}/rclone.1"

  file { '/opt':
    ensure => directory,
  }
  -> file { $install_dir:
    ensure  => directory,
  }

  file { $man_page_dir:
    ensure  => directory,
  }

  archive { 'download rclone':
    path         => $download_path,
    extract_path => $install_dir,
    source       => "https://downloads.rclone.org/v${version}/${instance}.zip",
    extract      => true,
    cleanup      => true,
    creates      => $instance_binary,
    require      => File[$install_dir]
  }

  file { $binary:
    source    => $instance_binary,
    owner     => 'root',
    mode      => '0755',
    subscribe => Archive['download rclone'],
  }

  file { $man_page:
    source    => $instance_man_page,
    owner     => 'root',
    subscribe => Archive['download rclone'],
  }
  ~> exec { 'rclone mandb':
    command     => 'mandb',
    path        => '/usr/bin',
    refreshonly => true,
    unless      => 'man rclone',
  }
}
