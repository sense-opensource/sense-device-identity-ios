

import Foundation
import UIKit
import CoreLocation
import SystemConfiguration
import Darwin
import Network
import CommonCrypto
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import AVFoundation
import MediaPlayer
import NetworkExtension
import AdSupport
import AppTrackingTransparency
import Foundation
import MachO
import ExternalAccessory
import Photos
import SystemConfiguration
import CryptoKit
import ObjectiveC
import MessageUI
import Contacts
import CoreGraphics
import CallKit
import Security
import DeviceActivity
import CoreTelephony

/* Get Device model */
func getDeviceModel() -> String {
    let deviceModel = UIDevice.current.name
    return deviceModel
}

/* Get Device Language info */
func getLanguageInfo() -> [String: Any]? {
    let deviceLanguage = Locale.preferredLanguages.first
    let currentLocale = Locale.current
    let languageName = currentLocale.localizedString(forLanguageCode: currentLocale.languageCode ?? "")
    let isoCode3 = Locale.isoLanguageCodes.first { currentLocale.localizedString(forLanguageCode: $0) == languageName }
    return [
        "language" : deviceLanguage ?? "",
        "displayLanguage" : languageName ?? "",
        "iso2Language" : isoCode3 ?? "",
    ]
}

/* Get country info */
func getCountryInfo() -> [String:Any]? {
    let deviceLocale = Locale.current
    let countryCode = (deviceLocale as NSLocale).object(forKey: .countryCode) as? String
    let countryName = deviceLocale.localizedString(forRegionCode: countryCode ?? "")
    let isoCode3 = Locale.isoRegionCodes.first { deviceLocale.localizedString(forRegionCode: $0) == countryName }
    
    return ["country" : countryCode ?? "",
            "displayCountry": countryName ?? "",
            "iso2Country": isoCode3 ?? ""]
}


/* Check whether data roaming is enabled */
func isDataRoamingEnabled() -> Bool {
    let telephonyInfo = CTTelephonyNetworkInfo()
    if let providers = telephonyInfo.serviceSubscriberCellularProviders {
        for (_, carrier) in providers {
            if carrier.allowsVOIP {
                return true
            }
        }
    }
    return false
}
/* Get Kernal version */
func getKernelVersion() -> String {
    let name = "kern.osrelease"
    var size: Int = 0
    sysctlbyname(name, nil, &size, nil, 0)
    var osrelease = [CChar](repeating: 0, count: size)
    sysctlbyname(name, &osrelease, &size, nil, 0)
    let kernelVersion = String(cString: osrelease)
    
    return kernelVersion
}

/* Check Data enabled or not */
func isDataEnabled() -> Bool {
    let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability!, &flags)
    return flags.contains(.reachable) && !flags.contains(.connectionRequired)
}

/* Get Network Type */
func getNetworkType() -> String {
    let telephonyInfo = CTTelephonyNetworkInfo()

    if let radioTechnologies = telephonyInfo.serviceCurrentRadioAccessTechnology {
        for (_, technology) in radioTechnologies {
            return technology
        }
    }
    return "Unknown"
}

/* Check the device whether Real device or Simulator */
extension UIDevice {
    static var isSimulator: Bool = {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }()
}

/* Get Battery Level */
func getBatteryLevel() -> String {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    let level = Int(device.batteryLevel * 100)
    return "\(level)%"
}

/* Get IP Address */
func getIPAddress() -> String {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            guard let interface = ptr?.pointee else { return "" }
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                let name: String = String(cString: (interface.ifa_name))
                if  name == "en0" || name == "en2" || name == "en3" || name == "en4" || name == "pdp_ip0" || name == "pdp_ip1" || name == "pdp_ip2" || name == "pdp_ip3" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
    }
    return address ?? ""
}

/* Check the Charging status */
func isCharging() -> String {
    UIDevice.current.isBatteryMonitoringEnabled = true
    
    let state = UIDevice.current.batteryState
    if state == .charging {
        return "Yes"
    } else {
        return "No"
    }
}

/* Get Memory Info */
func getMemoryInfo() -> [String:Any]? {
    if #available(iOS 13.0, *) {
        let totalMem = ProcessInfo.processInfo.physicalMemory
        let totalMemory = totalMem/(1024*1024)
        let availableMemory = os_proc_available_memory() / 1024 / 1024
        let usedMemory = Int64(totalMemory) - Int64(availableMemory)
        return [
            "totalMemory" : "\(totalMemory) mb",
            "availableMemory" : "\(availableMemory) mb",
            "usedMemory" : "\(usedMemory) mb"
        ]
    } else {
        return [:]
    }
}

/* Get memory info */
func getTest() -> [String:Any]? {
    var deviceMemory = [String:Any]()
    let device = UIDevice.current
    
    deviceMemory = [
        "Device model" : "\(device.model)",
        "System name" : "\(device.systemName)",
        "System version" : "\(device.systemVersion)"
    ]
    return deviceMemory
}

/* Get Total Disk Space */
func totalDiskSpace() -> String {
    let diskSpaceInBytes = totalDiskSpaceInBytes()
    if diskSpaceInBytes > 0 {
        return ByteCountFormatter.string(fromByteCount: diskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    return "The total disk space on this device is unknown"
}

func totalDiskSpaceInBytes() -> Int64 {
    do {
        guard let totalDiskSpaceInBytes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemSize] as? Int64 else {
            return 0
        }
        return totalDiskSpaceInBytes
    } catch {
        return 0
    }
}

func freeDiskSpaceInBytes() -> Int64 {
    do {
        guard let totalDiskSpaceInBytes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[FileAttributeKey.systemFreeSize] as? Int64 else {
            return 0
        }
        return totalDiskSpaceInBytes
    } catch {
        return 0
    }
}


func isGPSEnabled() -> Bool {
    let status = CLLocationManager.authorizationStatus()
    
    if CLLocationManager.locationServicesEnabled() {
        // Check the authorization status
        switch status {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        @unknown default:
            return false
        }
    } else {
        return false
    }
}


func usedDiskSpaceInBytes() -> Int64 {
    return totalDiskSpaceInBytes() - freeDiskSpaceInBytes()
}

func freeDiskSpace() -> String {
    let freeSpaceInBytes = freeDiskSpaceInBytes()
    if freeSpaceInBytes > 0 {
        return ByteCountFormatter.string(fromByteCount: freeSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    return "The free disk space on this device is unknown"
}

func usedDiskSpace() -> String {
    let usedSpaceInBytes = totalDiskSpaceInBytes() - freeDiskSpaceInBytes()
    if usedSpaceInBytes > 0 {
        return ByteCountFormatter.string(fromByteCount: usedSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.binary)
    }
    return "The used disk space on this device is unknown"
}

func getScreenColorDepth() -> Int {
    let screenScale = UIScreen.main.scale
    
    switch screenScale {
    case 1.0:
        return 24 // 24-bit color (standard resolution)
    case 2.0:
        return 24 // 24-bit color (Retina)
    case 3.0:
        return 24 // 24-bit color (Super Retina)
    default:
        return -1 // Unknown color depth
    }
}

/*  Check Device type */
func checkDeviceType() -> [String:Any]? {
    var deviceTypes = [String:Any]()
    
    var iPhone = false
    var iPad = false
    
    let devType = UIDevice.current.userInterfaceIdiom
    
    if(devType == .phone){
        iPhone = true
    }else if(devType == .pad){
        iPad = true
    }
    
    deviceTypes = [
        "isMobile" : false,
        "isSmartTV" : false,
        "isTablet" : false,
        "isiPad" : iPad,
        "isiPhone" : iPhone
    ]
    return deviceTypes
    
}

/* Jailbreak (not used) */
func canEditSandboxFilesForJailBreakDetecttion() -> Bool {
    let jailBreakTestText = "Test for JailBreak"
    do {
        try jailBreakTestText.write(toFile:"/private/jailBreakTestText.txt", atomically:true, encoding:String.Encoding.utf8)
        return true
    } catch {
        return false
    }
}

/* Get screen size */
public func screenSize() -> String? {
    let scale = UIScreen.main.scale
    
    let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163);
    
    let width = UIScreen.main.bounds.size.width * scale
    let height = UIScreen.main.bounds.size.height * scale
    
    let horizontal = width / ppi, vertical = height / ppi;
    
    let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))
    let screenSize = String(format: "%0.1f", diagonal)
    return screenSize
}

/*  Kernal Architecture */
func getDeviceArchitecture() -> String? {
    var size: size_t = 0
    sysctlbyname("hw.machine", nil, &size, nil, 0)
    
    var machine = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.machine", &machine, &size, nil, 0)
    
    return String(cString: machine)
}

/* Kernal Name (Name of the device’s kernel) */
func getKernelName() -> String? {
    var unameInfo = utsname()
    uname(&unameInfo)
    let sysname = withUnsafeBytes(of: &unameInfo.sysname) { rawBuffer in
        Array(rawBuffer.bindMemory(to: CChar.self))
    }
    return String(cString: sysname)
}

/* Current network (Check current network) */
func getNetworkConfiguration() -> String {
    let reachability = SCNetworkReachabilityCreateWithName(nil, "www.google.com")
    var flags = SCNetworkReachabilityFlags()
    SCNetworkReachabilityGetFlags(reachability!, &flags)
    if flags.contains(.reachable) {
        if flags.contains(.isWWAN) {
            return "Cellular"
        } else {
            return "WiFi"
        }
    } else {
        return "No Network"
    }
}

/* Check biometric enabled or not */
func isBiometricsEnabled() -> Bool {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        return true
    } else {
        // Biometrics not enabled or not available
        return false
    }
}

/* Check passcode enabled or not */
func isPasscodeEnabled() -> Bool {
    let context = LAContext()
    var error: NSError?
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
        return true
    } else {
        return false
    }
}

/* Check On call (Flags if the phone is on a call during the transaction) */
func isOnCall() -> Bool {
    let callObserver = CXCallObserver()
    let calls = callObserver.calls
    
    for call in calls {
        if call.hasConnected || call.isOutgoing || call.isOnHold {
            return true
        }
    }
    return false
}

/* Audio Muted (It indicates if the phone is muted or not) */
func isAudioMuted() -> Bool {
    let audioSession = AVAudioSession.sharedInstance()
    
    do {
        try audioSession.setActive(true)
        let currentVolume = audioSession.outputVolume
        
        if currentVolume == 0 {
            // The device is muted
            return true
        }
    } catch {
       
    }
    return false
}

/* Current Volume level (Current level of device system’s volume on a 0 to 100 scale) */
func getCurrentVolumeLevel() -> Float {
    let volumeView = MPVolumeView()
    
    if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
        return slider.value
    }
    
    return 0.0
}

/* CPU Count (Number of cores of the device’s CPU) */
func getCPUCount() -> Int {
    let processInfo = ProcessInfo()
    return processInfo.processorCount
}

/* CPU type (Type of the device’s CPU) */
func getCPUType() -> String? {
    var size = MemoryLayout<Int32>.size
    var cpuType: Int32 = 0
    
    if sysctlbyname("hw.cputype", &cpuType, &size, nil, 0) == 0 {
        switch cpuType {
        case Int32(CPU_TYPE_ARM):
            return "ARM"
        case Int32(CPU_TYPE_ARM64):
            return "ARM64"
        case Int32(CPU_TYPE_X86):
            return "x86"
        case Int32(CPU_TYPE_X86_64):
            return "x86_64"
        default:
            return nil
        }
    }
    return nil
}

/* Device Orientation */
func getDeviceOrientation() -> String {
    // Start generating device orientation notifications
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    
    let deviceOrientation = UIDevice.current.orientation
    
    switch deviceOrientation {
    case .portrait:
        return "Portrait"
    case .portraitUpsideDown:
        return "Portrait Upside Down"
    case .landscapeLeft:
        return "Landscape Left"
    case .landscapeRight:
        return "Landscape Right"
    case .faceUp:
        return "Face Up"
    case .faceDown:
        return "Face Down"
    case .unknown:
        fallthrough // Handle unknown state
    default:
        return "Unknown"
    }
}

/* CPU Speed */
func deviceModel() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else { return identifier }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
    return identifier
}

let deviceCPUFrequency: [String: Double] = [
    // iPhone 2G
    "iPhone1,1": 0.412,
    // iPhone 3G
    "iPhone1,2": 0.412,
    // iPhone 3GS
    "iPhone2,1": 0.600,
    // iPhone 4
    "iPhone3,1": 0.800, // GSM
    "iPhone3,2": 0.800, // GSM (Rev A)
    "iPhone3,3": 0.800, // CDMA
    // iPhone 4S
    "iPhone4,1": 0.800,
    // iPhone 5
    "iPhone5,1": 1.3,  // GSM
    "iPhone5,2": 1.3,  // Global
    // iPhone 5C
    "iPhone5,3": 1.3,
    "iPhone5,4": 1.3,
    // iPhone 5S
    "iPhone6,1": 1.3,  // GSM
    "iPhone6,2": 1.3,  // Global
    // iPhone 6 / 6 Plus
    "iPhone7,2": 1.4,  // 6
    "iPhone7,1": 1.4,  // 6 Plus
    // iPhone 6S / 6S Plus
    "iPhone8,1": 1.85, // 6S
    "iPhone8,2": 1.85, // 6S Plus
    // iPhone SE (1st generation)
    "iPhone8,4": 1.85,
    // iPhone 7 / 7 Plus
    "iPhone9,1": 2.34, // 7 (GSM+CDMA)
    "iPhone9,3": 2.34, // 7 (GSM)
    "iPhone9,2": 2.34, // 7 Plus (GSM+CDMA)
    "iPhone9,4": 2.34, // 7 Plus (GSM)
    // iPhone 8 / 8 Plus
    "iPhone10,1": 2.39, // 8 (GSM+CDMA)
    "iPhone10,4": 2.39, // 8 (GSM)
    "iPhone10,2": 2.39, // 8 Plus (GSM+CDMA)
    "iPhone10,5": 2.39, // 8 Plus (GSM)
    // iPhone X
    "iPhone10,3": 2.39, // GSM+CDMA
    "iPhone10,6": 2.39, // GSM
    // iPhone XS / XS Max / XR
    "iPhone11,2": 2.49, // XS
    "iPhone11,4": 2.49, // XS Max (China)
    "iPhone11,6": 2.49, // XS Max (Global)
    "iPhone11,8": 2.49, // XR
    // iPhone 11 / 11 Pro / 11 Pro Max
    "iPhone12,1": 2.65, // 11
    "iPhone12,3": 2.65, // 11 Pro
    "iPhone12,5": 2.65, // 11 Pro Max
    // iPhone SE (2nd generation)
    "iPhone12,8": 2.65,
    // iPhone 12 / 12 Mini / 12 Pro / 12 Pro Max
    "iPhone13,1": 3.1, // 12 Mini
    "iPhone13,2": 3.1, // 12
    "iPhone13,3": 3.1, // 12 Pro
    "iPhone13,4": 3.1, // 12 Pro Max
    // iPhone 13 / 13 Mini / 13 Pro / 13 Pro Max
    "iPhone14,4": 3.1, // 13 Mini
    "iPhone14,5": 3.1, // 13
    "iPhone14,2": 3.1, // 13 Pro
    "iPhone14,3": 3.1, // 13 Pro Max
    // iPhone SE (3rd generation)
    "iPhone14,6": 3.22,
    // iPhone 14 / 14 Plus / 14 Pro / 14 Pro Max
    "iPhone14,7": 3.46, // 14
    "iPhone14,8": 3.46, // 14 Plus
    "iPhone15,2": 3.46, // 14 Pro
    "iPhone15,3": 3.46  // 14 Pro Max
    // Add more models as needed
]

func getCPUSpeed() -> Double? {
    let model = deviceModel()
    return deviceCPUFrequency[model]
}


/* Cehck Debug or not */
func isDebuggerAttached() -> Bool {
    return getppid() != 1
}

/* Get Device ADID */
func getDeviceAdID() -> String? {
    let sharedASIdentifierManager = ASIdentifierManager.shared()
    let adID = sharedASIdentifierManager.advertisingIdentifier
    return adID.uuidString
}

/* Cloud Container Available */
func isICloudContainerAvailable() -> Bool {
    if FileManager.default.ubiquityIdentityToken != nil {
        return true
    } else {
        return false
    }
}

/* Get System Uptime */
 func getSystemUptime() -> TimeInterval {
    let processInfo = ProcessInfo.processInfo
    return processInfo.systemUptime
}

/* iOS app running on a Mac */
func isPossiblyIOSAppOnMac() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

/* Proximity Sensor detection */
func isProximitySensorAvailable() -> Bool {
    let device = UIDevice.current
    return device.isProximityMonitoringEnabled
}

/* Last Boot Time */
func getLastBootTime() -> Date? {
    var boottime = timeval()
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    var size = MemoryLayout<timeval>.stride
    
    let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
    if result == 0, boottime.tv_sec != 0 {
        return Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000)
    }
    return nil
}

/* Boot Time Info */
func formatDateToJSONString(date: Date) -> String {
    let dateFormatter = ISO8601DateFormatter()
    return dateFormatter.string(from: date)
}

func getBootTimeInfo() -> String {
    if let lastBootTime = getLastBootTime() {
        return formatDateToJSONString(date: lastBootTime) // Return formatted boot time
    } else {
        return "unknown"
    }
}

/* Detect Session ID */
func sessionID() -> String {
    let timestamp = Date().timeIntervalSince1970
    let random = Int.random(in: 0..<1000)
    let sessionID = "\(timestamp)-\(random)"
    return sessionID
}

/* Accessary Count */
func accessaryCount() -> Int {
    let accessoryManager = EAAccessoryManager.shared()
    let connectedAccessories = accessoryManager.connectedAccessories
    let accessoriesCount = connectedAccessories.count
    return accessoriesCount
}

/* Developer Mode */
func isDeveloperModeEnabled() -> Bool {
    var info = kinfo_proc()
    var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
    var size = MemoryLayout<kinfo_proc>.stride
    
    let sysctlResult = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
    assert(sysctlResult == 0, "sysctl failed")
    
    return (info.kp_proc.p_flag & P_TRACED) != 0
}

func getSIMCount() -> Int {
    let networkInfo = CTTelephonyNetworkInfo()
    if let carriers = networkInfo.serviceSubscriberCellularProviders {
        // Filter out nil or inactive carriers
        let activeSIMs = carriers.filter { $0.value.mobileNetworkCode != nil }
        return activeSIMs.count
    }
    return 0
}

func getLocalIPAddress() -> String? {
    var address: String?
    
    // Get a list of all network interfaces
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    if getifaddrs(&ifaddr) == 0 {
        var ptr = ifaddr
        while ptr != nil {
            let interface = ptr!.pointee
            
            // Check for IPv4 or IPv6 interfaces
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Get the interface name (e.g., en0 for Wi-Fi)
                let name = String(cString: interface.ifa_name)
                if name == "en0" || name == "pdp_ip0" {
                    // Wi-Fi is "en0", cellular is "pdp_ip0"
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let saLen = addrFamily == UInt8(AF_INET6) ? MemoryLayout<sockaddr_in6>.size : MemoryLayout<sockaddr_in>.size
                    if getnameinfo(interface.ifa_addr, socklen_t(saLen), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                        address = String(cString: hostname)
                    }
                }
            }
            ptr = interface.ifa_next
        }
        freeifaddrs(ifaddr)
    }
    
    return address
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}

/* Get Device Timezone */
func getDeviceTimezoneInfo() -> [String: Any] {
    
    let currentTimeZone = TimeZone.current
    
    var timezoneInfo: [String: Any] = [:]
    
    timezoneInfo["identifier"] = currentTimeZone.identifier
    let region = currentTimeZone.identifier.components(separatedBy: "/").first ?? "Unknown"
    timezoneInfo["region"] = region
    timezoneInfo["secondsFromGMT"] = currentTimeZone.secondsFromGMT()
    timezoneInfo["abbreviation"] = currentTimeZone.abbreviation() ?? "N/A"
    
    return timezoneInfo
}

func getCurrentTimeZoneCountry() -> String? {

    let timeZone = TimeZone.current
    let timeZoneIdentifier = timeZone.identifier // e.g., "America/New_York"
 
    let components = timeZoneIdentifier.split(separator: "/")
    guard components.count > 1 else { return nil }

    let locale = Locale.current
    if let countryCode = locale.regionCode,
       let countryName = locale.localizedString(forRegionCode: countryCode) {
        return countryName
    }
    
    return nil
}


func getNetwork() -> String {
    let networkInfo = CTTelephonyNetworkInfo()
    guard let currentRadioTech = networkInfo.serviceCurrentRadioAccessTechnology?.values.first else {
        return "Unknown"
    }
    
    if #available(iOS 14.1, *) {
        switch currentRadioTech {
        case CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyGPRS:
            return "2G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
            CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0, CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyLTE:
            return "4G LTE"
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        default:
            return "Unknown"
        }
    } else {
        // Fallback on earlier versions
    }
    return "Unknown"
}

func getDeviceName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    // Convert the C-style array to a Swift String
    let machine = withUnsafePointer(to: &systemInfo.machine) { ptr in
        return String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
    }
    
    // Mapping the machine identifier to a human-readable device name
    switch machine {
        // iPhone 6s and iPhone 6s Plus
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"

        // iPhone SE (1st generation)
        case "iPhone8,4": return "iPhone SE (1st generation)"

        // iPhone 7 and iPhone 7 Plus
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"

        // iPhone 8 and iPhone 8 Plus
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"

        // iPhone X, XR, XS, and XS Max
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,6", "iPhone11,4": return "iPhone XS Max"

        // iPhone 11 Series
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"

        // iPhone SE (2nd generation)
        case "iPhone12,8": return "iPhone SE (2nd generation)"

        // iPhone 12 Series
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"

        // iPhone 13 Series
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"

        // iPhone SE (3rd generation)
        case "iPhone14,6": return "iPhone SE (3rd generation)"

        // iPhone 14 Series
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"

        // iPhone 15 Series
        case "iPhone15,4": return "iPhone 15"
        case "iPhone15,5": return "iPhone 15 Plus"
        case "iPhone16,1": return "iPhone 15 Pro"
        case "iPhone16,2": return "iPhone 15 Pro Max"

        // iPhone 16 Series (Placeholder for future updates, replace identifiers when available)
        case "iPhone16,x": return "iPhone 16"
        case "iPhone16,y": return "iPhone 16 Pro"

        // iPad Models
        case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19": return "iPad (10th generation)"

        // iPad Air Models
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"

        // iPad Mini Models
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
        case "iPad5,1", "iPad5,2": return "iPad mini 4"
        case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
        case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"

        // iPad Pro Models
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch, 1st generation)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch, 2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch, 1st generation)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch, 3rd generation)"
        case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch, 2nd generation)"
        case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch, 4th generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch, 3rd generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch, 5th generation)"
        case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch, 4th generation)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch, 6th generation)"

        // Default case
        default:
            return "Unknown device (\(machine))"
    }
}

func getNetworkName(completion: @escaping (String) -> Void) {
    // 1. Check for Wi-Fi
    if isWiFiConnected() {
        if let ssid = getWiFiSSID(), isMobileHotspot(ssid: ssid) {
            completion("Mobile Hotspot")
            return
        } else {
            completion("Wi-Fi")
            return
        }
    }
    
    // 2. Check for Ethernet (Wired Connection)
    if isEthernetConnected() {
        completion("Ethernet (Wired)")
        return
    }
    
    // 3. Check for Cellular (4G/5G)
    if let cellularInfo = getCellularNetworkType() {
        completion(cellularInfo)
        return
    }
    
    // If no connection type was detected
    completion("No Network")
}

private func isWiFiConnected() -> Bool {
    let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
    var isConnected = false
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied && path.usesInterfaceType(.wifi) {
            isConnected = true
        }
        semaphore.signal()
    }
    
    let queue = DispatchQueue(label: "MonitorQueue")
    monitor.start(queue: queue)
    semaphore.wait()
    
    return isConnected
}

private func isEthernetConnected() -> Bool {
    let monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)
    var isConnected = false
    let semaphore = DispatchSemaphore(value: 0)
    
    monitor.pathUpdateHandler = { path in
        if path.status == .satisfied && path.usesInterfaceType(.wiredEthernet) {
            isConnected = true
        }
        semaphore.signal()
    }
    
    let queue = DispatchQueue(label: "MonitorQueue")
    monitor.start(queue: queue)
    semaphore.wait()
    
    return isConnected
}

private func getCellularNetworkType() -> String? {
    let networkInfo = CTTelephonyNetworkInfo()

    if let serviceRadioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology {
        for (_, radioAccessTechnology) in serviceRadioAccessTechnology {
            return mapRadioAccessTechnologyToNetworkType(radioAccessTechnology)
        }
    }
    return "Unknown Cellular"
}

private func mapRadioAccessTechnologyToNetworkType(_ technology: String) -> String {
    if #available(iOS 14.1, *) {
        switch technology {
        case CTRadioAccessTechnologyNRNSA, CTRadioAccessTechnologyNR:
            return "5G"
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2G"
        default:
            return "Unknown Cellular"
        }
    } else {
        switch technology {
        case CTRadioAccessTechnologyLTE:
            return "4G"
        case CTRadioAccessTechnologyWCDMA, CTRadioAccessTechnologyHSDPA, CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMA1x, CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA, CTRadioAccessTechnologyCDMAEVDORevB:
            return "3G"
        case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge:
            return "2G"
        default:
            return "Unknown Cellular"
        }
    }
}

private func getWiFiSSID() -> String? {
    // Retrieve the SSID of the connected Wi-Fi network (this works only if you have permissions)
    if let interfaces = CNCopySupportedInterfaces() as? [String] {
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any] {
                return info["SSID"] as? String
            }
        }
    }
    return nil
}

private func isMobileHotspot(ssid: String) -> Bool {
    let hotspotIdentifiers = [
        "iPhone",
        "Android Hotspot",
        "My Mobile Hotspot",
        "Mobile Hotspot"
    ]
    
    // If the SSID matches one of the hotspot names, consider it as a mobile hotspot
    return hotspotIdentifiers.contains(where: { ssid.contains($0) })
}
// Check installed apps
func checkInstalledApps(packageList: [(packageName: String, packageCode: String)]) -> [String: Bool] {
    var result: [String: Bool] = [:]

    for (packageName, packageCode) in packageList {
        if let url = URL(string: "\(packageCode)://"), UIApplication.shared.canOpenURL(url) {
            result[packageName] = true
        } else {
            result[packageName] = false
        }
    }

    return result
}

/* Get Location Information */
func getLocationInfo() -> [String:Any]? {
    if #available(iOS 13.0, *) {
        if(SenseOS.lastLocation == nil && SenseOS.geoCode == nil){
            return ["latitude" : "",
                    "longitude":  "",
                    "accuracy": "",
                    "zipcode": "",
                    "city": "",
                    "region": "",
                    "countryCode": ""
            ]
        }else{
            var locationInfo: [String: Any] = [
                "latitude": SenseOS.lastLocation?.coordinate.latitude ?? "",
                "longitude": SenseOS.lastLocation?.coordinate.longitude ?? "",
                "accuracy": SenseOS.lastLocation?.horizontalAccuracy ?? "",
            ]
            
            if let geoCode = SenseOS.geoCode {
                locationInfo["zipcode"] = geoCode["zipcode"] ?? ""
                locationInfo["city"] = geoCode["city"] ?? ""
                locationInfo["region"] = geoCode["region"] ?? ""
                locationInfo["countryCode"] = geoCode["countryCode"] ?? ""
            } else {
                locationInfo["zipcode"] = ""
                locationInfo["city"] = ""
                locationInfo["region"] = ""
                locationInfo["countryCode"] = ""
            }
            
            return locationInfo
        }
    } else {
       return [
        "latitude" : "",
        "longitude":  "",
        "accuracy": "",
        "zipcode": "",
        "city": "",
        "region": "",
        "countryCode": ""
       ]
    }
}
    
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var locationStatus: CLAuthorizationStatus?
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    // Expose a method to start location updates
    func startUpdatingLocation() {
        DispatchQueue.global(qos: .background).async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        
        // Start location updates only if permission is granted
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    startUpdatingLocation()
                }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        SenseOS.lastLocation = location

        geocoder.reverseGeocodeLocation(location) { placemarks, error in

            if let placemark = placemarks?.first {
                let zipcode = placemark.postalCode ?? ""
                let city = placemark.locality ?? ""
                let region = placemark.administrativeArea ?? ""
                let countryCode = placemark.isoCountryCode ?? ""

                SenseOS.geoCode = [
                    "zipcode": zipcode,
                    "city": city,
                    "region": region,
                    "countryCode": countryCode
                ]
            }
        }
        // Stop updating location if needed to save battery
        stopUpdatingLocation()
    }
    
}

class ScreenMirroringDetector {
    
    static func isScreenMirroringActive() -> Bool {
        let screens = UIScreen.screens
        
        if screens.count > 1 {
            return true
        }
        
        if let mainScreen = screens.first, mainScreen.mirrored != nil {
                return true
            }
        
        return false
    }
}

class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    func save(_ value: String, for key: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary

            SecItemDelete(query)
            SecItemAdd(query, nil)
        }
    }

    func read(for key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        if let data = result as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }

    func getOrCreateSenseID() -> String {
        let key = "co.getsense.keychain"

        if let existingHashedID = read(for: key) {
            return existingHashedID
        } else {
            let newUUID = UUID().uuidString
            let hashedID = murmurHash3_x64_128(input: newUUID)
            save(hashedID, for: key)
            return hashedID
        }
    }
}

