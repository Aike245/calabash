module Calabash
  # Contains the Android implementations of the Calabash APIs.
  module Android
    TEST_SERVER_CODE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'android', 'test-server')
    UNSIGNED_TEST_SERVER_APK = File.join(File.dirname(__FILE__), 'android', 'lib', 'TestServer.apk')
    ANDROID_MANIFEST_PATH = File.join(File.dirname(__FILE__), 'android', 'lib', 'AndroidManifest.xml')

    require 'calabash'
    include Calabash

    # @!visibility private
    def self.extended(base)
      Calabash.send(:extended, base)
    end

    # @!visibility private
    def self.included(base)
      Calabash.send(:included, base)
    end

    require 'calabash/android/environment'

    require 'calabash/android/application'
    require 'calabash/android/build'
    require 'calabash/android/device'
    require 'calabash/android/screenshot'
    require 'calabash/android/server'
    require 'calabash/android/adb'
    require 'calabash/android/gestures'
    require 'calabash/android/interactions'
    require 'calabash/android/orientation'
    require 'calabash/android/physical_buttons'
    require 'calabash/android/text'
    require 'calabash/android/console_helpers'
    require 'calabash/android/life_cycle'

    include Calabash::Android::Gestures
    include Calabash::Android::Interactions
    include Calabash::Android::LifeCycle
    include Calabash::Android::Orientation
    include Calabash::Android::PhysicalButtons
    include Calabash::Android::Text

    # @!visibility private
    def self.binary_location(name, abi, using_pie)
      binary_name = if using_pie
                      "#{name}-pie"
                    else
                      name
                    end

      file = File.join(File.dirname(__FILE__), 'android', 'lib', name, abi, binary_name)

      unless File.exist?(file)
        raise "No such file '#{file}'"
      end

      file
    end
  end
end

# Setup environment on load
Calabash::Android::Environment.setup
