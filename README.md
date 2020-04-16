# Puppet Rclone management module

Puppet module helping with installation and configuration of [Rclone](https://rclone.org/)

*Disclaimer:*
This module is in early stage of development - everything are subject to change. Any feedback or help is welcomed.

## Description
Use this module to automate installation and configuration of [Rclone](https://rclone.org/) - cloud rsync tool.

## Setup

### Setup Requirements
Depends on following modules:
* puppet/archive

### Beginning with rclone
```puppet
class { 'rclone':
  ensure => 'desired rclone version'
}

# configure s3
rclone::config::s3 { 'my_S3':
  access_key_id     => 'AKI...',
  secret_access_key => '...',
  os_user           => 'my_user',
  region            => 'eu-west-1',
}
```

## Usage
See [reference guide](REFERENCE.md)

## Limitations
Module in early stage, anything can break anytime.

## Development
*Prerequisites*: Installed ruby, gem and bundler and also [PDK](https://puppet.com/docs/pdk/1.x/pdk_install.html) can help.
```bash
bundle update
bundle install
```

### Run unit tests
```bash
bundle exec rake spec
```
or with PDK
```bash
pdk test unit
```

### Generate reference
```bash
bundle exec rake strings:generate:reference
```
