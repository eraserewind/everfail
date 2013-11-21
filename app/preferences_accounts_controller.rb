class PreferencesAccountsController < NSViewController
  stylesheet :preferences_window

  layout do
    @txt = subview(NSTextField, :title_upload, stringValue: 'Accounts llol')
  end

  def identifier
    "Accounts"
  end

  def toolbarItemImage
    NSImage.imageNamed("skitch")
  end

  def toolbarItemLabel
    "Accounts"
  end

  def initialKeyView
    @txt
  end

end

