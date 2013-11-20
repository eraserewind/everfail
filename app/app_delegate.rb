class AppDelegate
  def applicationDidFinishLaunching(notification)
    #buildMenu
    #buildWindow
    buildStatus(setupMenu)
    prefs.registerDefaults({ 'notificationcenter' => true, 'copy' => true })
  end

  def buildStatus(menu)
    @statusBar = NSStatusBar.systemStatusBar
    @item = @statusBar.statusItemWithLength(NSVariableStatusItemLength)
    @item.retain
    @item.setImage(NSImage.imageNamed("menu"))
    @item.setHighlightMode(false)
    @item.setMenu(menu)
  end

  def appName
    @appName ||= NSBundle.mainBundle.infoDictionary['CFBundleName']
  end

  def prefs
    NSUserDefaults.standardUserDefaults
  end

  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle appName
    menu.addItem createMenuItem('Selection Screenshot', 'screenshotSelection:')
    menu.addItem createMenuItem('Window Screenshot', 'screenshotWindow:')
    menu.addItem createMenuItem('Fullscreen Screenshot', 'screenshotScreen:')

    menu.addItem NSMenuItem.separatorItem
    menu.addItem createMenuItem('Preferences', 'openPreferences:')
    menu.addItem sparklezMenuItemz
    menu.addItem NSMenuItem.separatorItem

    # Basic stuff
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
    @mainWindow.title = appName
    @mainWindow.orderFrontRegardless
  end

  private

  def createMenuItem(name, action, key='')
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: key)
  end

  def takeScreenshot(sender, args='-i')
    Dispatch::Queue.concurrent.async do
      @item.setTitle("")
      fileName = "#{appName.downcase}_#{Time.now.to_i}.png"
      tempFile = "#{NSTemporaryDirectory()}#{fileName}"
      puts "tempfile is #{tempFile}"
      system("screencapture #{args} -t png #{tempFile}")
      puts "screen ok"
      @item.setTitle("↑")
      state, str = upload(fileName, tempFile)
      if state
        @item.setTitle("")
        pasteToClipboard(str) if prefs.boolForKey('copy')
        sendNotification("Screenshot uploaded", "#{str} (copied)") if prefs.boolForKey('notificationcenter')
      else
        @item.setTitle("!")
        sendNotification("Screenshot upload failure", str)
      end
    end
  end

  def upload(name, file)
    case prefs.stringForKey('up_method')
    when "scp"
      user = prefs.stringForKey('up_user')
      host = prefs.stringForKey('up_host')
      path = prefs.stringForKey('up_path')
      url_p = prefs.stringForKey('up_url')
      if user && host && path && url_p
        system("scp -v #{file} #{user}@#{host}:#{path}")
        if url_p[url_p.size-1] == "/"
          uri = "#{url_p}#{name}"
        else
          uri = "#{url_p}/#{name}"
        end
      else
        return [false, "SCP misconfigured :("]
      end
    else
      return [false, "Invalid upload method"]
    end
    [true, uri]
  end

  def sendNotification(title, text)
    notif = NSUserNotification.alloc.init
    notif.setTitle(title)
    notif.setInformativeText(text)
    notif.setDeliveryDate(NSDate.dateWithTimeInterval(1, sinceDate: NSDate.date))
    notif.setSoundName(NSUserNotificationDefaultSoundName)
    center = NSUserNotificationCenter.defaultUserNotificationCenter
    center.scheduleNotification(notif)
  end

  def pasteToClipboard(string)
    pb = NSPasteboard.generalPasteboard
    pb.clearContents()
    pb.writeObjects(NSArray.arrayWithObject(string))
  end

  def sparklezMenuItemz
    sparkle = createMenuItem("Check for updates...", nil)
    sparkle.setTarget SUUpdater.new
    sparkle.setAction 'checkForUpdates:'
  end

end
