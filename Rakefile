# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require_relative 'lib/template_nosign'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'EverFail'
  app.copyright = 'Copyright © 2013 Renegade Replicants. all rights reserved'
  app.identifier = 'net.renegadereplicants.everfail'
  app.version = '0.0.6'
  app.info_plist['NSUIElement'] = 1
  app.icon = "icon.png"

  app.pods do
    pod 'FTPManager'
    pod 'AFAmazonS3Client'
    pod 'RHPreferences'
  end

  app.sparkle do
    # Required setting
    release :base_url, 'http://everfail.apps.rngd.io/releases/current'

    # Recommended setting
    # This will set both your `app.version` and `app.short_version` to the same value
    # It's fine not to use it, just remember to set both as Sparkle needs them
    release :version, '0.0.6'

    # Optional settings and their default values
    release :feed_filename, 'releases.xml'
    release :notes_filename, 'release_notes.html'
    release :package_filename, "#{app.name}.zip"
    release :public_key, 'dsa_pub.pem'

  end
end

task :scp_release do
  `scp sparkle/release/* nibiru:/storage1/jordan/sites/everfail.apps.rngd.io/releases/current`
end
