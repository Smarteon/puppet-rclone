# @summary S3 configuration for Rclone.
#
# Ensures S3 Rclone configuration of given name and params. Include of `rclone` is required.
# Currently only AWS provider is supported.
#
# @example
#   rclone::config::s3 { 's3_remote':
#     os_user           => 'my_user',
#     access_key_id     => 'SOME_ACCESS_KEY',
#     secret_access_key => 'SECRET_ACCESS_KEY',
#     region            => 'us-east-1',
#   }
#
# @param ensure
#   configuration ensure
# @param os_user
#   operating system user - used to execute rclone commands, effective configuration owner
# @param config_name
#   configuration name - should be unique among Rclone configurations, defaults to title
# @param access_key_id
#   S3 provider's access_key_id, maps to Rclone `access_key_id` property
# @param secret_access_key
#   S3 provider's secret_access_key, maps to Rclone `secret_access_key` property
# @param region
#   S3 provider's region, maps to Rclone `region` property
# @param s3_provider
#   S3 provider, maps to Rclone `provider` property
# @param canned_acl
#   S3 canned ACL, maps to Rclone `acl` property
# @param endpoint
#   S3 provider's endpoint, maps to Rclone `endpoint` property
# @param location_constraint
#   S3 location_constraint, maps to Rclone `location_constraint` property
# @param location_constraint
#   S3 location_constraint, maps to Rclone `location_constraint` property
# @param server_side_encryption
#   S3 server_side_encryption, maps to Rclone `server_side_encryption` property
# @param storage_class
#   S3 storage_class, maps to Rclone `storage_class` property
define rclone::config::s3 (
  String $os_user,
  String $access_key_id,
  String $secret_access_key,
  String $region,
  Enum['present', 'absent'] $ensure = 'present',
  String $config_name = $title,
  Enum['AWS'] $s3_provider = 'AWS',
  Optional[String] $canned_acl = undef,
  Optional[String] $endpoint = undef,
  Optional[String] $location_constraint = undef,
  Optional[String] $server_side_encryption = undef,
  Optional[String] $storage_class = undef,
) {

  $_options = {
    provider               => $s3_provider,
    env_auth               => 'false',
    access_key_id          => $access_key_id,
    secret_access_key      => $secret_access_key,
    region                 => $region,
    acl                    => $canned_acl,
    endpoint               => $endpoint,
    location_constraint    => $location_constraint,
    server_side_encryption => $server_side_encryption,
    storage_class          => $storage_class,
  }

  rclone::config { $config_name:
    ensure  => $ensure,
    os_user => $os_user,
    type    => 's3',
    options => $_options,
  }

}
