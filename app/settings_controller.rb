class SettingsController < TeacupWindowController
  stylesheet :settings_window

  layout do
    prefs = NSUserDefaults.standardUserDefaults
    @bools = {}
    @strings = {}

    # Screenshot format
    subview(NSTextField, "format_label".to_sym, stringValue: "Format")
    @strings["format"] = format = subview(NSComboBox, :format)
    formats = %w(png jpg gif tiff pdf)
    formats.each do |n|
      format.addItemWithObjectValue(n)
    end
    format.setDelegate(self)
    index = formats.index(prefs.stringForKey("format")) || 'png'
    format.selectItemAtIndex(index)

    # Booleans
    %w(notify copy open_url sound).each do |x|
      @bools[x] = subview(NSButton, x.to_sym)
      @bools[x].setState(prefs.boolForKey(x) ? NSOnState : NSOffState)
    end
  end

  def identifier
    "Settings"
  end

  def toolbarItemImage
    NSImage.imageNamed("261")
  end

  def toolbarItemLabel
    "Settings"
  end

  def view
    @view ||= top_level_view
  end

  def commitEditing
    prefs = NSUserDefaults.standardUserDefaults
    @strings.each { |name, field| prefs.setObject(field.stringValue, forKey: name) }
    @bools.each { |name, butt| prefs.setObject(butt.state == 1, forKey: name) }
    prefs.synchronize
  end

  def loadWindow
    self.window = NSWindow.alloc.initWithContentRect([[240, 180], [480, 185]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
  end

end

