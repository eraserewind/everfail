class AppDelegate
  def applicationDidFinishLaunching(notification)
    #buildMenu
    #buildWindow
    buildStatus(setupMenu)
  end

  def buildStatus(menu)
    @statusBar = NSStatusBar.systemStatusBar
    @item = @statusBar.statusItemWithLength(NSVariableStatusItemLength)
    @item.retain
    @item.setImage(NSImage.imageNamed("menu"))
    #@item.setTitle("EverFail")
    @item.setHighlightMode(true)
    @item.setMenu(menu)
  end

  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle 'EverFail'
    menu.addItem createMenuItem('Selection Screenshot', 'screenshotSelection:')
    menu.addItem createMenuItem('Window Screenshot', 'screenshotWindow:')
    menu.addItem createMenuItem('Fullscreen Screenshot', 'screenshotScreen:')
    menu.addItem createMenuItem('Quit', 'terminate:')
    menu
  end

  def screenshotScreen(sender)
    takeScreenshot(sender)
  end

  def screenshotWindow(sender)
    takeScreenshot(sender, '-W')
  end

  def screenshotSelection(sender)
    takeScreenshot(sender, '-i')
  end

  private

  def createMenuItem(name, action, key='')
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: key)
  end

  def takeScreenshot(sender, args='-i')
    fileName = "everfail_#{Time.now.to_i}.png"
    tempFile = "#{NSTemporaryDirectory()}#{fileName}"
    puts "tempfile is #{tempFile}"
    system("screencapture #{args} -t png #{tempFile}")
    puts "screen ok"
    system("scp -v #{tempFile} creature@nibiru.r:/storage1/jordan/sites/jordan.io/-/")
    puts "up ok"
    uri = "http://jordan.io/-/#{fileName}"
    pb = NSPasteboard.generalPasteboard
    pb.clearContents()
    pb.writeObjects(NSArray.arrayWithObject(uri))
  end

end
