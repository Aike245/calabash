require 'calabash'
require 'calabash/ios'
require 'calabash/ios/api'

World(Calabash)
World(Calabash::IOS::API)

Calabash::Application.default = Calabash::IOS::Application.default_from_environment

identifier = Calabash::IOS::Device.default_identifier_for_application(Calabash::Application.default)
server = Calabash::IOS::Server.default

Calabash::Device.default = Calabash::IOS::Device.new(identifier, server)

unless Calabash::Environment.xamarin_test_cloud?
  require 'pry'
end
