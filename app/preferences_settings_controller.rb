class PreferencesSettingsController < NSViewController
  stylesheet :preferences_window

  layout do
    @txt = subview(NSTextField, :title_upload, stringValue: 'Settings Mdr')
  end

  def identifier
    "Settings"
  end

  def toolbarItemImage
    NSImage.imageNamed("skitch")
  end

  def toolbarItemLabel
    "Settings"
  end

  def initialKeyView
    @txt
  end

end

