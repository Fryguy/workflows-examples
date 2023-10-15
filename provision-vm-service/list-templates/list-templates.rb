#!/usr/bin/env ruby

require "manageiq-api-client"

# Image-specific parameters
ems_id = ENV.fetch("PROVIDER_ID")

# ManageIQ API login
secrets = JSON.load(File.read(ENV.fetch("_CREDENTIALS")))
secrets.transform_keys! { |k| k.sub(/^api_/, "").to_sym }

url        = ENV.fetch("API_URL", "http://localhost:3000")
verify_ssl = ENV.fetch("VERIFY_SSL", "true") == "true"

api_options = {url: url, ssl: {verify: verify_ssl}}.merge(secrets)
api = ManageIQ::API::Client.new(api_options)

# Get the list of templates
resources = api.templates.where(:ems_id => ems_id).pluck(:ems_ref, :name)

# Output the list of templates in JSON format to STDOUT
puts({"values" => resources.to_h}.to_json)
