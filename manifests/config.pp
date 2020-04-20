# @summary General configuration for Rclone.
#
# Ensures Rclone configuration of given name, type and params. Include of `rclone` is required.
#
# @example
#   rclone::config { 'my_remote':
#     os_user => 'my_user',
#     type    => 'ftp',
#     options => {...}
#   }
#
# @param ensure
#   configuration ensure
# @param os_user
#   operating system user - used to execute rclone commands, effective configuration owner
# @param type
#   configuration remote type
# @param options
#   configuration options - Hash of options for `rclone config` command
# @param config_name
#   configuration name - should be unique among Rclone configurations, defaults to title
define rclone::config (
  String $os_user,
  Enum[
    'amazon cloud drive',
    'azureblob',
    'b2',
    'box',
    'crypt',
    'cache',
    'chunker',
    'drive',
    'dropbox',
    'fichier',
    'ftp',
    'google cloud storage',
    'google photos',
    'http',
    'swift',
    'hubic',
    'jottacloud',
    'koofr',
    'local',
    'mailru',
    'mega',
    'memory',
    'onedrive',
    'opendrive',
    'pcloud',
    'premiumizeme',
    'putio',
    'qingstor',
    's3',
    'sftp',
    'sharefile',
    'sugarsync',
    'union',
    'webdav',
    'yandex'] $type,
  Hash[String, Optional[String]] $options,
  Enum['present', 'absent'] $ensure = 'present',
  String $config_name = $title,
) {

  if ! defined(Class[rclone]) {
    fail('You must include the rclone base class before using any defined resources')
  }

  $_operation = $ensure ? {
    'present' => 'create',
    'absent'  => 'delete',
    default   => fail("Invalid ensure value '${ensure}'")
  }

  $_options = $options.filter |$key, $val| { $val != undef }.convert_to(Array).flatten()

  exec { "rclone ${_operation} remote ${config_name} for user ${os_user}":
    command => shell_join(['rclone', 'config', $_operation, $config_name]
      + if ($_operation == 'create') { [$type] + $_options } else { [] }),
    user    => $os_user,
    path    => '/usr/bin',
    require => Class[rclone],
  }
}
