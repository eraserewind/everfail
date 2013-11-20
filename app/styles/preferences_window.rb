Teacup::Stylesheet.new :preferences_window do
  style :sparkles_button,
    frame: NSMakeRect(10, 10, 135, 32),
    title: "Check for updates",
    bezelStyle: NSRoundedBezelStyle,
    autoresizingMask: autoresize.fixed_top_right

  style :about_button,
    frame: NSMakeRect(385, 10, 80, 32),
    title: "About",
    bezelStyle: NSRoundedBezelStyle,
    autoresizingMask: autoresize.fixed_top_right

end

