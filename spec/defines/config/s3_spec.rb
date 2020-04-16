# frozen_string_literal: true

require 'spec_helper'

describe 'rclone::config::s3' do
  let(:title) { 'test_r' }
  let(:params) do
    {
      os_user: 'user',
      access_key_id: 'aws_id',
      secret_access_key: 'aws_key',
      region: 'eu-west-1',
    }
  end

  context 'on missing rclone main class' do
    it { is_expected.to compile.and_raise_error(%r{include the rclone base class}) }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) { 'include rclone' }

      it { is_expected.to compile }

      it {
        is_expected.to contain_exec('rclone create remote test_r for user user')
          .with(
            command: 'rclone config create test_r s3 \\' \
              "\nprovider AWS env_auth false access_key_id aws_id secret_access_key aws_key region eu-west-1 \\\n\n",
            user: 'user',
            path: '/usr/bin',
          )
          .that_requires('Class[rclone]')
      }

      context 'with optional params' do
        let(:params) do
          super().merge(
            canned_acl: 'private',
            endpoint: 'some-s3.com',
            location_constraint: 'eu-west-1',
            server_side_encryption: 'AES256',
            storage_class: 'STANDARD',
          )
        end

        it {
          is_expected.to contain_exec('rclone create remote test_r for user user')
            .with(
              command: 'rclone config create test_r s3 \\' \
                "\nprovider AWS env_auth false access_key_id aws_id secret_access_key aws_key region eu-west-1 \\" \
                "\nacl private endpoint some-s3.com location_constraint eu-west-1 server_side_encryption AES256 storage_class STANDARD\n",
              user: 'user',
              path: '/usr/bin',
            )
            .that_requires('Class[rclone]')
        }
      end

      context 'with ensure => absent' do
        let(:params) do
          super().merge(ensure: 'absent')
        end

        it {
          is_expected.to contain_exec('rclone delete remote test_r for user user')
            .with(
              command: 'rclone config delete test_r',
              user: 'user',
              path: '/usr/bin',
            )
            .that_requires('Class[rclone]')
        }
      end
    end
  end
end
