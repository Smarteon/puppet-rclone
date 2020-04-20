# @summary Google Drive configuration for Rclone.
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

  $_options = {
    client_id                   => $client_id,
    client_secret               => $client_secret,
    service_account_credentials => $service_account_credentials,
    scope                       => $scope,
    root_folder_id              => $root_folder_id,
    team_drive                  => $team_drive,
  }

  rclone::config { $config_name:
    ensure  => $ensure,
    os_user => $os_user,
    type    => 'drive',
    options => $_options,
  }

}
