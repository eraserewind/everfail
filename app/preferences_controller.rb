class PreferencesController < TeacupWindowController
  stylesheet :preferences_window

  layout do
    prefs = NSUserDefaults.standardUserDefaults
    @strings = {}
    subview(NSTextField, :title_upload, stringValue: 'Upload')

    subview(NSTextField, "up_method_label".to_sym, stringValue: "Method")
    @strings["up_method"] = up_method = subview(NSComboBox, :up_method)
    methods = %w(SCP FTP S3)
    methods.each do |n|
      up_method.addItemWithObjectValue(n)
    end
    up_method.setDelegate(self)
    index = methods.index(prefs.stringForKey("up_method")) || 0
    up_method.selectItemAtIndex(index)

    %w(host user pass path url).each do |f|
      subview(NSTextField, "up_#{f}_label".to_sym, stringValue: f.capitalize)
      @strings["up_#{f}"] = subview(NSTextField, "up_#{f}".to_sym, stringValue: prefs.stringForKey("up_#{f}"))
    end

    subview(NSButton, :save_button, action: 'savePreferences:', target: self)
    subview(NSButton, :sparkles_button, action: 'checkForUpdates:', target: SUUpdater.new)
    subview(NSButton, :about_button, action: 'orderFrontStandardAboutPanel:', target: NSApplication.sharedApplication.delegate)
    comboBoxSelectionDidChange
  end

  def savePreferences(sender)
    prefs = NSUserDefaults.standardUserDefaults
    @strings.each do |name, field|
      prefs.setObject(field.stringValue, forKey: name)
    end

    prefs.synchronize
    window.performClose(sender)
  end

  def comboBoxSelectionDidChange(notif=nil)
    if notif
      comboBox = notif.object
      method = comboBox.itemObjectValueAtIndex(comboBox.indexOfSelectedItem)
    else
      method = @strings["up_method"].stringValue
    end
    case method
    when "SCP"
      @strings["up_pass"].setEnabled(false) if @strings["up_pass"]
    else
      @strings["up_pass"].setEnabled(true) if @strings["up_pass"]
    end
  end
end

