# @summary Ensures Rclone installed
#
# @api private
class rclone::install {

  $_os = $facts['os']['family'] ? {
    /(Debian|Ubuntu)/ => 'linux',
    default           => fail("Unsupported OS family ${facts['os']['family']}"),
  }

  $_architecture = $facts['os']['architecture'] ? {
    /arm.*/          => 'arm',
    /aarch64/        => 'arm64',
    /(amd64|x86_64)/ => 'amd64',
  }

  $_version = $rclone::ensure ? {
    /latest/ => rclone::last_version(),
    default  => $rclone::ensure,
  }

  $_download_path = '/tmp/rclone.zip'
  $_instance = "rclone-v${_version}-${_os}-${_architecture}"
  $_instance_binary = "${rclone::install_dir}/${_instance}/rclone"
  $_instance_man_page = "${rclone::install_dir}/${_instance}/rclone.1"

  if !defined(File['/opt']) {
    file { '/opt':
      ensure => directory,
      before => File[$rclone::install_dir],
    }
  }

  file { $rclone::install_dir:
    ensure  => directory,
  }

  if !defined(File[$rclone::man_page_dir]) {
    file { $rclone::man_page_dir:
      ensure => directory,
      before => File[$rclone::man_page],
    }
  }

  archive { 'download rclone':
    path         => $_download_path,
    extract_path => $rclone::install_dir,
    source       => "https://downloads.rclone.org/v${_version}/${_instance}.zip",
    extract      => true,
    cleanup      => true,
    creates      => $_instance_binary,
    require      => File[$rclone::install_dir]
  }

  file { $_instance_binary:
    owner     => 'root',
    mode      => '0755',
    subscribe => Archive['download rclone'],
  }

  file { $rclone::binary:
    ensure    => link,
    target    => $_instance_binary,
    subscribe => Archive['download rclone'],
  }

  file { $rclone::man_page:
    ensure    => link,
    target    => $_instance_man_page,
    subscribe => Archive['download rclone'],
    notify    => Exec['rclone mandb'],
  }
}
