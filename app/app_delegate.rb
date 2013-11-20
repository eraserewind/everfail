class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    #buildWindow
    buildStatus(setupMenu)
    prefs.registerDefaults({ 'notificationcenter' => true, 'copy' => true, 'up_pass' => '', 'up_user' => '', 'up_method' => '', 'up_path' => '', 'up_url' => '' })
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
    @mainWindow = @controller.window
    @mainWindow.title = appName + " Preferences"
    @mainWindow.styleMask = NSTitledWindowMask | NSClosableWindowMask
    @mainWindow.makeKeyAndOrderFront(sender)
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
      system("screencapture #{args} -t png #{tempFile}")
      @item.setTitle("↑")
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
    pasteToClipboard(str) if prefs.boolForKey('copy')
    sendNotification("Screenshot uploaded", "#{str} (copied)") if prefs.boolForKey('notificationcenter')
  end

  def uploadFailure(str)
    @item.setTitle("!")
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
    unless prefz[:user].empty? && prefz[:host].empty? && prefz[:path].empty? && prefz[:url].empty?
      command = "scp #{file} #{prefz[:user]}@#{prefz[:host]}:#{prefz[:path]} 2>&1"
      NSLog("SCP: Running '#{command}'")
      reason = "no output"
      out = IO.popen(command) { |line|
        str = line.read.to_s
        NSLog("SCP: out: #{str}")
        reason = str
      }
      process = $?
      if process.exitstatus > 0
        [ false, "SCP Error (#{process.exitstatus}): #{reason}" ]
      else
        [true, buildUrlFor(name)]
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
    notif.setSoundName(NSUserNotificationDefaultSoundName)
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

end
