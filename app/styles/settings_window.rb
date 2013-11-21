Teacup::Stylesheet.new :settings_window do
  import :app

  style :format_label, extends: :text,
    frame: NSMakeRect(10, 145, 80, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :format,
    frame: NSMakeRect(80, 145, 60, 25),
    editable: false,
    selectable: true,
    autoresizingMask: autoresize.fill_top

  style :notify, extends: :checkbox,
    frame: NSMakeRect(10, 100, 300, 30),
    title: "Notify Notification Center on successful upload"

  style :copy, extends: :checkbox,
    frame: NSMakeRect(10, 70, 300, 30),
    title: "Copy URL to clipboard"

  style :open_url, extends: :checkbox,
    frame: NSMakeRect(10, 40, 300, 30),
    title: "Open screenshot in browser"

  style :sound, extends: :checkbox,
    frame: NSMakeRect(10, 10, 300, 30),
    title: "Make sounds"
end
