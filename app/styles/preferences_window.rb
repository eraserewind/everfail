Teacup::Stylesheet.new :preferences_window do
  style :save_button,
    frame: NSMakeRect(10, 10, 60, 32),
    title: "Save",
    bezelStyle: NSRoundedBezelStyle,
    autoresizingMask: autoresize.fixed_bottom_left

  style :sparkles_button,
    frame: NSMakeRect(145, 10, 135, 32),
    title: "Check for updates",
    bezelStyle: NSRoundedBezelStyle,
    autoresizingMask: autoresize.fixed_bottom_left

  style :about_button,
    frame: NSMakeRect(385, 10, 80, 32),
    title: "About",
    bezelStyle: NSRoundedBezelStyle,
    autoresizingMask: autoresize.fixed_bottom_right

  style :text,
    drawsBackground: false,
    bezeled: false,
    editable: false,
    selectable: false

  style :h1, extends: :text,
    font: NSFont.boldSystemFontOfSize(14.0)

  style :title_upload, extends: :h1,
    frame: NSMakeRect(10, 318, 100, 30),
    autoresizingMask: autoresize.fixed_top_left

  # -- Upload form

  style :up_method_label, extends: :text,
    frame: NSMakeRect(30, 290, 80, 22),
    autoresizingMask: autoresize.fixed_top_left

  style :up_method,
    frame: NSMakeRect(100, 290, 100, 22),
    autoresizingMask: autoresize.fill_top

  style :up_host_label, extends: :text,
    frame: NSMakeRect(30, 260, 80, 22),
    autoresizingMask: autoresize.fixed_top_left

  style :up_host,
    frame: NSMakeRect(100, 260, 300, 22),
    autoresizingMask: autoresize.fill_top

  style :up_user_label, extends: :text,
    frame: NSMakeRect(30, 230, 80, 22),
    autoresizingMask: autoresize.fixed_top_left

  style :up_user,
    frame: NSMakeRect(100, 230, 300, 22),
    autoresizingMask: autoresize.fill_top

  style :up_path_label, extends: :text,
    frame: NSMakeRect(30, 200, 80, 22),
    autoresizingMask: autoresize.fixed_top_left

  style :up_path,
    frame: NSMakeRect(100, 200, 300, 22),
    autoresizingMask: autoresize.fill_top

  style :up_url_label, extends: :text,
    frame: NSMakeRect(30, 170, 80, 22),
    autoresizingMask: autoresize.fixed_top_left

  style :up_url,
    frame: NSMakeRect(100, 170, 300, 22),
    autoresizingMask: autoresize.fill_top
  



end

