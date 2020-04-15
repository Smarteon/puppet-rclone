# frozen_string_literal: true

require 'spec_helper'

describe 'rclone' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      os_arch = os_facts[:architecture]
      bin_install_path = '/usr/bin/rclone'
      man_install_path = '/usr/local/share/man/man1/rclone.1'

      it { is_expected.to compile }

      context 'with ensure => current' do
        let(:params) { { ensure: 'current' } }

        it { is_expected.to compile.and_raise_error(%r{'ensure' expects a match for Pattern}) }
      end

      context 'with ensure => latest' do
        let(:params) { { ensure: 'latest' } }

        before(:each) do
          stub_request(:get, 'https://downloads.rclone.org/version.txt').to_return(body: 'rclone v1000.0.1')
        end

        it { is_expected.to contain_class('rclone::install') }

        describe 'rclone::install' do
          it { is_expected.to compile }

          install = "rclone-v1000.0.1-linux-#{os_arch}"
          install_path = "/opt/rclone/#{install}"
          bin_path = "#{install_path}/rclone"
          man_path = "#{install_path}/rclone.1"

          it {
            is_expected.to contain_file('/opt/rclone')
              .with(ensure: 'directory', path: '/opt/rclone')
          }
          it {
            is_expected.to contain_file(bin_path)
              .with(path: bin_path, mode: '0755')
              .that_subscribes_to('Archive[download rclone]')
          }
          it {
            is_expected.to contain_file(bin_install_path)
              .with(ensure: 'link', path: bin_install_path, target: bin_path)
              .that_subscribes_to('Archive[download rclone]')
          }
          it {
            is_expected.to contain_file(man_install_path)
              .with(ensure: 'link', path: man_install_path, target: man_path)
              .that_subscribes_to('Archive[download rclone]')
              .that_notifies('Exec[rclone mandb]')
          }
          it {
            is_expected.to contain_archive('download rclone')
              .with(
                extract_path: '/opt/rclone',
                source: "https://downloads.rclone.org/v1000.0.1/#{install}.zip",
                extract: true,
                creates: bin_path,
              )
              .that_requires('File[/opt/rclone]')
          }
        end
      end

      context 'with ensure => 1.2.3' do
        let(:params) { { ensure: '1.2.3' } }

        it { is_expected.to contain_class('rclone::install') }

        describe 'rclone::install' do
          it { is_expected.to compile }

          install = "rclone-v1.2.3-linux-#{os_arch}"
          install_path = "/opt/rclone/#{install}"
          bin_path = "#{install_path}/rclone"
          man_path = "#{install_path}/rclone.1"

          it {
            is_expected.to contain_file('/opt/rclone')
              .with(ensure: 'directory', path: '/opt/rclone')
          }
          it {
            is_expected.to contain_file(bin_path)
              .with(path: bin_path, mode: '0755')
              .that_subscribes_to('Archive[download rclone]')
          }
          it {
            is_expected.to contain_file(bin_install_path)
              .with(ensure: 'link', path: bin_install_path, target: bin_path)
              .that_subscribes_to('Archive[download rclone]')
          }
          it {
            is_expected.to contain_file(man_install_path)
              .with(ensure: 'link', path: man_install_path, target: man_path)
              .that_subscribes_to('Archive[download rclone]')
              .that_notifies('Exec[rclone mandb]')
          }
          it {
            is_expected.to contain_archive('download rclone')
              .with(
                extract_path: '/opt/rclone',
                source: "https://downloads.rclone.org/v1.2.3/#{install}.zip",
                extract: true,
                creates: bin_path,
              )
              .that_requires('File[/opt/rclone]')
          }
        end
      end

      context 'with ensure => absent' do
        let(:params) { { ensure: 'absent' } }

        it { is_expected.to contain_class('rclone::uninstall') }

        describe 'rclone::uninstall' do
          it { is_expected.to compile }

          it {
            is_expected.to contain_file("remove #{man_install_path}")
              .with(ensure: 'absent', path: man_install_path)
              .that_notifies('Exec[rclone mandb]')
          }

          it {
            is_expected.to contain_file('remove /usr/bin/rclone')
              .with(ensure: 'absent', path: '/usr/bin/rclone')
          }

          it {
            is_expected.to contain_file('remove /opt/rclone')
              .with(ensure: 'absent', path: '/opt/rclone', purge: true, recurse: true, force: true)
          }
        end
      end
    end
  end
end
