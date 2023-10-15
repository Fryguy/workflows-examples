#!/usr/bin/env ruby

require "json"
require "manageiq-api-client"

# Image-specific parameters
provider_type = ENV.fetch("PROVIDER_TYPE", nil)

# ManageIQ API login
secrets = JSON.load(File.read(ENV.fetch("_CREDENTIALS")))
secrets.transform_keys! { |k| k.sub(/^api_/, "").to_sym }

url        = ENV.fetch("API_URL", "http://localhost:3000")
verify_ssl = ENV.fetch("VERIFY_SSL", "true") == "true"

api_options = {url: url, ssl: {verify: verify_ssl}}.merge(secrets)
api = ManageIQ::API::Client.new(api_options)

# Get the list of providers
response = api.providers
response = response.where(:type => provider_type) if provider_type
response = response.pluck(:id, :name)

# Output the list of providers in JSON format to STDOUT
puts({"values" => response.to_h}.to_json)
