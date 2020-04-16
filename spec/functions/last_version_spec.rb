# frozen_string_literal: true

require 'spec_helper'

describe 'rclone::last_version' do
  before(:each) do
    stub_request(:get, 'https://downloads.rclone.org/version.txt').to_return(body: "rclone v1000.0.1\n")
  end

  it { is_expected.to run.and_return('1000.0.1') }
end
