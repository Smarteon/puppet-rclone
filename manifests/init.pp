# @summary Download and install Rclone
#
# Install rclone binary and man page
#
# @param [String] version
#   installed version
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

  if !defined(File['/opt']) {
    file { '/opt':
      ensure => directory,
      before => File[$install_dir],
    }
  }

  file { $install_dir:
    ensure  => directory,
  }

  if !defined(File[$man_page_dir]) {
    file { $man_page_dir:
      ensure => directory,
      before => File[$man_page],
    }
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

  file { $instance_binary:
    owner     => 'root',
    mode      => '0755',
    subscribe => Archive['download rclone'],
  }

  file { $binary:
    ensure    => link,
    target    => $instance_binary,
    subscribe => Archive['download rclone'],
  }

  file { $man_page:
    ensure    => link,
    target    => $instance_man_page,
    subscribe => Archive['download rclone'],
  }
  ~> exec { 'rclone mandb':
    command     => 'mandb',
    path        => '/usr/bin',
    refreshonly => true,
    unless      => 'man rclone',
  }
}
