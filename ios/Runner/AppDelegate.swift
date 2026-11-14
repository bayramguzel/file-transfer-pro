import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var transferBackgroundTask: UIBackgroundTaskIdentifier = .invalid
  private var incomingFileChannel: FlutterMethodChannel?
  private var pendingIncomingFile: URL?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // iOS 10+ : uygulama on plandayken de bildirimlerin gosterilmesi icin
    // bildirim merkezinin delegesi FlutterAppDelegate olmalidir.
    UNUserNotificationCenter.current().delegate = self

    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Dosyalar uygulamasindan / diger uygulamalardan "Ac" ile gelen dosyalar
    // Dart tarafina iletilir (Share Extension ve App Group gerektirmez).
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "file_transfer/incoming_file",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        if call.method == "getInitialFile" {
          let path = self?.pendingIncomingFile?.path
          self?.pendingIncomingFile = nil
          result(path)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
      incomingFileChannel = channel
    }

    if let url = launchOptions?[.url] as? URL {
      queueIncomingFile(url)
    }

    return launched
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if url.isFileURL {
      queueIncomingFile(url)
    }
    // URL semasini kullanan eklentilerin de haberdar olmasi icin super cagrilir.
    _ = super.application(app, open: url, options: options)
    return true
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    // iOS arka planda uygulamayi birkac saniye icinde askiya alir ve yerel
    // dosya sunucusu kapanir. Aktarim surerken baglanti kopmasin diye kisa
    // sureli ek calisma izni istenir (iOS'un verdigi sure kadar, ~30 sn).
    if transferBackgroundTask == .invalid {
      transferBackgroundTask = application.beginBackgroundTask(withName: "fileTransferServer") { [weak self] in
        guard let self = self else { return }
        if self.transferBackgroundTask != .invalid {
          application.endBackgroundTask(self.transferBackgroundTask)
          self.transferBackgroundTask = .invalid
        }
      }
    }
    super.applicationDidEnterBackground(application)
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    endTransferBackgroundTask()
    super.applicationWillEnterForeground(application)
  }

  override func applicationWillTerminate(_ application: UIApplication) {
    endTransferBackgroundTask()
    super.applicationWillTerminate(application)
  }

  private func endTransferBackgroundTask() {
    if transferBackgroundTask != .invalid {
      UIApplication.shared.endBackgroundTask(transferBackgroundTask)
      transferBackgroundTask = .invalid
    }
  }

  /// Gelen dosyayi uygulama kasasindaki Inbox klasorune kopyalar ve Dart
  /// tarafina haber verir. Kopyalama basarisiz olursa (dosya zaten kasada)
  /// dogrudan yol paylasilir.
  private func queueIncomingFile(_ url: URL) {
    guard url.isFileURL else { return }

    let fileManager = FileManager.default
    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let inbox = documents.appendingPathComponent("Inbox", isDirectory: true)
    try? fileManager.createDirectory(at: inbox, withIntermediateDirectories: true)

    let accessed = url.startAccessingSecurityScopedResource()
    defer {
      if accessed { url.stopAccessingSecurityScopedResource() }
    }

    var target = inbox.appendingPathComponent(url.lastPathComponent)
    var counter = 1
    while fileManager.fileExists(atPath: target.path) {
      let base = url.deletingPathExtension().lastPathComponent
      let ext = url.pathExtension
      let name = ext.isEmpty ? "\(base)_\(counter)" : "\(base)_\(counter).\(ext)"
      target = inbox.appendingPathComponent(name)
      counter += 1
    }

    do {
      try fileManager.copyItem(at: url, to: target)
      deliverIncomingFile(target)
    } catch {
      deliverIncomingFile(url)
    }
  }

  private func deliverIncomingFile(_ url: URL) {
    pendingIncomingFile = url
    incomingFileChannel?.invokeMethod("openFile", arguments: url.path)
  }
}
