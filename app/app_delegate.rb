class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildStatus(setupMenu)
    prefs.registerDefaults({ 'notify' => true, 'copy' => true, 'open_url' => false, 'sound' => false, 'format' => 'png',
      'up_pass' => '', 'up_user' => '', 'up_method' => '', 'up_path' => '', 'up_url' => '', 'scp_opts' => '' })
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
    menu.addItem createMenuItem('Preferences', 'showPreferences:')
    menu.addItem sparklezMenuItemz
    menu.addItem NSMenuItem.separatorItem

    # Basic stuff
    menu.addItem createMenuItem("About #{appName}", 'orderFrontStandardAboutPanel:')
    menu.addItem createMenuItem('Quit', 'terminate:')

    menu
  end

  def screenshotScreen(sender)
    takeScreenshot(sender, '-w -S')
  end

  def screenshotWindow(sender)
    takeScreenshot(sender, '-w')
  end

  def screenshotSelection(sender)
    takeScreenshot(sender, '-i')
  end

  def showPreferences(sender)
    unless @preferencesWindowController
      settings = SettingsController.new
      accounts = AccountsController.new
      controllers = [settings, accounts]
      @preferencesWindowController = RHPreferencesWindowController.alloc.initWithViewControllers(controllers, andTitle: "Preferences")
    end
    @preferencesWindowController.showWindow(self)
    @preferencesWindowController.showWindow(self)
    @preferencesWindowController.showWindow(self)
  end

  def openOldPreferences(sender)
    @controller = PreferencesController.new
    @mainWindow = @controller.window
    @mainWindow.title = appName + " Preferences"
    @mainWindow.styleMask = NSTitledWindowMask | NSClosableWindowMask
    @mainWindow.orderFrontRegardless
  end

  private

  def createMenuItem(name, action, key='')
    NSMenuItem.alloc.initWithTitle(name, action: action, keyEquivalent: key)
  end

  def takeScreenshot(sender, args='-i')
    Dispatch::Queue.concurrent.async do
      @item.setTitle("")
      fileName = "#{appName.downcase}_#{Time.now.to_i}.#{prefs.stringForKey('format')}"
      tempFile = "#{NSTemporaryDirectory()}#{fileName}"
      nosoundarg = prefs.boolForKey('sound') ? "" : "-x"
      command = "/usr/sbin/screencapture #{args} -t #{prefs.stringForKey('format')} #{nosoundarg} #{tempFile}"
      NSLog("ScreenCapture command: #{command.inspect}")
      reason = "no output"
      out = IO.popen(command) { |line|
        str = line.read.to_s
        NSLog("ScreenCapture: out: #{str}")
        reason = str
      }
      process = $?
      if process.exitstatus > 0
        NSLog("Screencapture failed #{process.exitstatus}")
        sendNotification("Screen Capture error", "Exit #{process.exitstatus}: #{reason}")
        return
      end

      @item.setTitle("↑")
      @item.setImage(NSImage.imageNamed("menu-uploading"))
      state, str = upload(fileName, tempFile)
      if state
        uploadSuccess(str)
      elsif state == false
        uploadFailure(str)
      end
    end
  end

  def uploadSuccess(str)
    @item.setTitle("")
    @item.setImage(NSImage.imageNamed("menu"))
    pasteToClipboard(str) if prefs.boolForKey('copy')
    sendNotification("Screenshot uploaded", "#{str} (copied)") if prefs.boolForKey('notify')
    NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(str)) if prefs.boolForKey('open_url')
  end

  def uploadFailure(str)
    @item.setTitle("!")
    @item.setImage(NSImage.imageNamed("menu-error"))
    sendNotification("Screenshot upload failure", str)
  end

  def upload(name, file)
    prefz = {
      user: prefs.stringForKey('up_user'),
      pass: prefs.stringForKey('up_pass'),
      host: prefs.stringForKey('up_host'),
      path: prefs.stringForKey('up_path'),
      url: prefs.stringForKey('up_url')
    }
    case prefs.stringForKey('up_method').downcase.to_sym
    when :scp
      uploadSCP(name, file, prefz)
    when :ftp
      uploadFTP(name, file, prefz)
    when :s3
      uploadS3(name, file, prefz)
    else
      [false, "Invalid upload method"]
    end
  end

  def uploadSCP(name, file, prefz)
    unless prefz[:user].empty? && prefz[:host].empty? && prefz[:path].empty? && prefz[:url].empty? && prefz[:pass].empty?
      host_can_use_publickey = false # TODO support keys
      NSLog("SCP to #{prefz[:user]}@#{prefz[:host]}")
      session = NMSSHSession.connectToHost(prefz[:host], withUsername: prefz[:user])
      if session.isConnected
        methods = session.supportedAuthenticationMethods
        if methods.include?("password")
          session.authenticateByPassword(prefz[:pass])
        # TODO: Support keys authentication
        elsif methods.include?("publickey") && host_can_use_publickey == true
          NSLog("TODO: Add publickey support :)")
        # TODO: Really support keyboard interactive (ask the user if pass is empty or other request
        elsif methods.include?("keyboard-interactive")
          NSLog("SCP: Authenticating by keyboard interactive.")
          session.authenticateByKeyboardInteractiveUsingBlock(lambda do |request|
            NSLog("Keyboard interactive request: #{request}")
            prefz[:pass] if request == 'Password:'
          end)
        else
          return [ false, "Unsupported SSH authentication methods (#{methods.join(',')}" ]
        end

        if session.isAuthorized
          NSLog("SCP authenticated!")
        else
          return [ false, "SCP Authorization failure" ]
        end
      end

      success = session.channel.uploadFile(file, to: prefz[:path])
      session.disconnect
      if success
        [ true, buildUrlFor(name) ]
      else
        [ false, "SCP upload failed" ]
      end
    else
      [false, "SCP misconfigured :("]
    end
  end

  def uploadFTP(name, file, prefz)
    return [false, "FTP misconfigured"] if prefz[:user].empty? && prefz[:host].empty? && prefz[:path].empty? && prefz[:url].empty? && prefz[:pass].empty?
    manager = FTPManager.alloc.init
    server = FMServer.serverWithDestination("ftp://#{prefz[:host]}#{prefz[:path]}", username: prefz[:user], password: prefz[:pass])
    NSLog("FTP: Uploading #{file} to ftp://#{prefz[:host]}#{prefz[:path]}")
    success = manager.uploadFile(NSURL.URLWithString(file), toServer: server)
    if success
      [ true, buildUrlFor(name) ]
    else
      [ false, "FTP Error" ]
    end
  end

  # Does not work because https://github.com/AFNetworking/AFAmazonS3Client/issues/26
  def uploadS3(name, file, prefz)
    return [false, "S3 misconfigured"] if prefz[:user].empty? && prefz[:host].empty? && prefz[:path].empty? && prefz[:url].empty? && prefz[:pass].empty?
    s3 = AFAmazonS3Client.alloc.initWithAccessKeyID(prefz[:user].strip, secret: prefz[:pass].strip)
    puts "#{prefz[:user].strip.inspect} #{prefz[:pass].strip.inspect}"
    bucket, path = prefz[:path].gsub(/^\//, '').split('/', 2)
    s3.bucket = bucket
    NSLog("S3 bucket #{bucket}")
    url = path.nil? ? "https://#{prefz[:host]}/#{bucket}/" : "https://#{prefz[:host]}/#{bucket}/#{path}/#{name}"
    NSLog("S3 destinationPath #{url}")
    params = { "Content-Type" => "image/png", "acl" => "public-read" }
    s3.postObjectWithFile(file, destinationPath: "/", parameters: params,
      progress: lambda do |bytesWritten, totalBytesWritten, totalBytesExpectedToWrite|
        stats = (totalBytesWritten / (totalBytesExpectedToWrite * 1.0) * 100)
        NSLog("S3: #{file} uploaded #{stats}")
      end,
      success: lambda do |response|
        NSLog("S3: #{file} uploaded successfully.")
        uploadSuccess(url + "/#{name}")
      end,
      failure: lambda do |error|
        NSLog("S3: #{file} upload error: #{error.localizedDescription}")
        uploadFailure("S3 Error: #{error.localizedDescription}")
      end
    )
    nil
  end

  def buildUrlFor(name)
    prefix = prefs.stringForKey('up_url')
    if prefix[prefix.size-1] == "/"
      uri = "#{prefix}#{name}"
    else
      uri = "#{prefix}/#{name}"
    end
  end

  def sendNotification(title, text)
    notif = NSUserNotification.alloc.init
    notif.setTitle(title)
    notif.setInformativeText(text)
    notif.setSoundName(NSUserNotificationDefaultSoundName) if prefs.boolForKey('sound')
    center = NSUserNotificationCenter.defaultUserNotificationCenter
    center.deliverNotification(notif)
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

  # Alert window
  def buildAlertWindow
    @alertWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @alertWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @alertWindow.orderFrontRegardless
  end

end
