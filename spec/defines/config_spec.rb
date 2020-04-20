# frozen_string_literal: true

require 'spec_helper'

describe 'rclone::config' do
  let(:title) { 'test_r' }
  let(:params) do
    {
      os_user: 'user',
      type: 'local',
      options: {},
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
            command: 'rclone config create test_r local',
            user: 'user',
            path: '/usr/bin',
          )
          .that_requires('Class[rclone]')
      }

      context 'with options' do
        let(:params) do
          super().merge(options: { option_a: 'some_val', option_b: :undef, option_c: '\\a $"&' })
        end

        it {
          is_expected.to contain_exec('rclone create remote test_r for user user')
            .with(
              command: 'rclone config create test_r local option_a some_val option_c \\\a\ \$\\"\&',
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
