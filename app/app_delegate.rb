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
    @item.setHighlightMode(false)
    @item.setMenu(menu)
  end

  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle 'EverFail'
    menu.addItem createMenuItem('Selection Screenshot', 'screenshotSelection:')
    menu.addItem createMenuItem('Window Screenshot', 'screenshotWindow:')
    menu.addItem createMenuItem('Fullscreen Screenshot', 'screenshotScreen:')

    menu.addItem NSMenuItem.separatorItem
    menu.addItem createMenuItem('Preferences', 'openPreferences:')
    menu.addItem sparklez_menu_itemz
    menu.addItem NSMenuItem.separatorItem

    # Basic stuff
    appName = NSBundle.mainBundle.infoDictionary['CFBundleName']
    menu.addItem createMenuItem("About #{appName}", 'orderFrontStandardAboutPanel:')
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

  def openPreferences(sender)
    @controller = PreferencesController.new
    @mainWindow = @controller.window #(styleMask: NSMiniaturizableWindowMask)
    # @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
    #   styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
    #   backing: NSBackingStoreBuffered,
    #   defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
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
    @item.setTitle("↑")
    system("scp -v #{tempFile} creature@nibiru.r:/storage1/jordan/sites/jordan.io/-/")
    @item.setTitle("")
    puts "up ok"
    uri = "http://jordan.io/-/#{fileName}"
    pb = NSPasteboard.generalPasteboard
    pb.clearContents()
    pb.writeObjects(NSArray.arrayWithObject(uri))
    notif = NSUserNotification.alloc.init
    notif.setTitle("Screenshot uploaded")
    notif.setInformativeText("#{uri} (copied)")
    notif.setDeliveryDate(NSDate.dateWithTimeInterval(1, sinceDate: NSDate.date))
    notif.setSoundName(NSUserNotificationDefaultSoundName)
    center = NSUserNotificationCenter.defaultUserNotificationCenter
    center.scheduleNotification(notif)
  end

  def sparklez_menu_itemz
    sparkle = createMenuItem("Check for updates...", nil)
    sparkle.setTarget SUUpdater.new
    sparkle.setAction 'checkForUpdates:'
  end

end
