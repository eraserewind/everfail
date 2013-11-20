class PreferencesController < TeacupWindowController
  stylesheet :preferences_window

  layout do
    prefs = NSUserDefaults.standardUserDefaults
    @strings = {}
    subview(NSTextField, :title_upload, stringValue: 'Upload')

    %w(method host user path url).each do |f|
      subview(NSTextField, "up_#{f}_label".to_sym, stringValue: f.capitalize)
      @strings["up_#{f}"] = subview(NSTextField, "up_#{f}".to_sym, stringValue: prefs.stringForKey("up_#{f}"))
    end

    subview(NSButton, :save_button, action: 'savePreferences:', target: self)
    subview(NSButton, :sparkles_button, action: 'checkForUpdates:', target: SUUpdater.new)
    subview(NSButton, :about_button, action: 'orderFrontStandardAboutPanel:', target: NSApplication.sharedApplication.delegate)
  end

  def savePreferences(sender)
    prefs = NSUserDefaults.standardUserDefaults
    @strings.each do |name, field|
      prefs.setObject(field.stringValue, forKey: name)
    end

    prefs.synchronize
  end
end

