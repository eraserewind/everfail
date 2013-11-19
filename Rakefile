# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

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
  app.version = '0.0.1'
  app.info_plist['NSUIElement'] = 1
end
