class AccountsController < TeacupWindowController
  stylesheet :accounts_window

  layout do
    prefs = NSUserDefaults.standardUserDefaults
    @strings = {}

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
      @strings["up_#{f}"] = subview(NSTextField, "up_#{f}".to_sym, stringValue: prefs.stringForKey("up_#{f}") || '')
    end

    comboBoxSelectionDidChange
  end

  def savePreferences(sender=nil)
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
    #case method
    #when "SCP"
    #  @strings["up_pass"].setEnabled(false) if @strings["up_pass"]
    #else
    #  @strings["up_pass"].setEnabled(true) if @strings["up_pass"]
    #end
  end

  def identifier
    "Upload"
  end

  def toolbarItemImage
    NSImage.imageNamed("175")
  end

  def toolbarItemLabel
    "Upload"
  end

  def view
    @view ||= top_level_view
  end

  def commitEditing
    savePreferences
  end

  def loadWindow
    self.window = NSWindow.alloc.initWithContentRect([[240, 180], [480, 215]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
  end

end

