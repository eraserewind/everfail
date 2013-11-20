class PreferencesController < TeacupWindowController
  stylesheet :preferences_window

  layout do
    subview(NSButton, :sparkles_button, action: 'checkForUpdates:', target: SUUpdater.new)
    subview(NSButton, :about_button, action: 'orderFrontStandardAboutPanel:', target: AppDelegate)
  end
end

