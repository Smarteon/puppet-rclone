# frozen_string_literal: true

require 'net/http'

# @summary Fetches the last released Rclone version from internet
#
# @api private
Puppet::Functions.create_function(:'rclone::last_version') do
  # @return [String] last released Rclone version
  def last_version
    uri = URI('https://downloads.rclone.org/version.txt')
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request Net::HTTP::Get.new(uri)
      response.body.gsub(%r{.*rclone v(\d+\.\d+\.\d+).*}m, '\1')
    end
  end
end
