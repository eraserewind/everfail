Teacup::Stylesheet.new :accounts_window do
  import :app

  style :up_method_label, extends: :text,
    frame: NSMakeRect(10, 170, 60, 25)

  style :up_method,
    frame: NSMakeRect(80, 170, 60, 25),
    editable: false,
    selectable: true,
    autoresizingMask: autoresize.fill_top

  style :up_host_label, extends: :text,
    frame: NSMakeRect(10, 130, 60, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :up_host,
    frame: NSMakeRect(80, 130, 365, 25),
    autoresizingMask: autoresize.fill_top

  style :up_user_label, extends: :text,
    frame: NSMakeRect(10, 100, 60, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :up_user,
    frame: NSMakeRect(80, 100, 365, 25),
    autoresizingMask: autoresize.fill_top

  style :up_pass_label, extends: :text,
    frame: NSMakeRect(10, 70, 60, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :up_pass,
    frame: NSMakeRect(80, 70, 365, 25),
    autoresizingMask: autoresize.fill_top

  style :up_path_label, extends: :text,
    frame: NSMakeRect(10, 40, 60, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :up_path,
    frame: NSMakeRect(80, 40, 365, 25),
    autoresizingMask: autoresize.fill_top

  style :up_url_label, extends: :text,
    frame: NSMakeRect(10, 10, 60, 25),
    autoresizingMask: autoresize.fixed_top_left

  style :up_url,
    frame: NSMakeRect(80, 10, 365, 25),
    autoresizingMask: autoresize.fill_top



end

