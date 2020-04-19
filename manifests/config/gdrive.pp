# @summary Google Drive confguration for Rclone.
#
# Ensures Drive Rclone configuration of given name and params. Include of `rclone` is required.
# Support only service account credentials (token authentication requires human interaction when setup).
#
# @example
#   rclone::config::gdrive { 'drive_remote':
#     os_user                     => 'my_user',
#     client_id                   => 'SOME_CLIENT_ID',
#     client_secret               => 'SOME_CLIENT_SECRET',
#     service_account_credentials => 'SERVICE_CREDENTIALS',
#   }
#
# @param ensure
#   configuration ensure
# @param os_user
#   operating system user - used to execute rclone commands, effective configuration owner
# @param config_name
#   configuration name - should be unique among Rclone configurations, defaults to title
# @param client_id
#   Google drive client_id, maps to Rclone `client_id` property
# @param client_secret
#   Google drive client_secret, maps to Rclone `client_secret` property
# @param service_account_credentials
#   Google drive service_account_credentials, maps to Rclone `service_account_credentials` property
# @param scope
#   Google drive access scope, maps to Rclone `scope` property
# @param root_folder_id
#   Id of the drive root folder, maps to Rclone `root_folder_id` property
# @param team_drive
#   Id of the team drive, maps to Rclone `team_drive` property
define rclone::config::gdrive (
  String $os_user,
  String $client_id,
  String $client_secret,
  String $service_account_credentials,
  Enum['present', 'absent'] $ensure = 'present',
  String $config_name = $title,
  String $scope = 'drive',
  Optional[String] $root_folder_id = undef,
  Optional[String] $team_drive = undef,
) {

  if ! defined(Class[rclone]) {
    fail('You must include the rclone base class before using any defined resources')
  }

  $_rclone_exec_defaults = {
    user => $os_user,
    path => '/usr/bin',
    require => Class[rclone],
  }

  case $ensure {
    'present': {

      $_options = {
        root_folder_id => $root_folder_id,
        team_drive => $team_drive,
      }
        .filter |$key, $val| { $val != undef }.map |$key, $val| { "${key} ${val}" }.join(' ')

      exec { default: *=> $_rclone_exec_defaults; "rclone create remote ${config_name} for user ${os_user}":
        command => @("CMD")
          rclone config create ${config_name} drive \
          client_id ${client_id} client_secret ${client_secret} service_account_credentials ${service_account_credentials} scope ${scope} \
          ${_options}
          | CMD
      }
    }

    'absent': {
      exec { default: *=> $_rclone_exec_defaults; "rclone delete remote ${config_name} for user ${os_user}":
        command => "rclone config delete ${config_name}",
      }
    }

    default: {
      fail("Invalid ensure value '${ensure}'")
    }
  }

}
