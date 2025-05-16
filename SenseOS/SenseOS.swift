


import Foundation
import UIKit
import CoreTelephony
import MapKit
import CoreLocation
import Network
import CommonCrypto
import SystemConfiguration.CaptiveNetwork
import LocalAuthentication
import AVFoundation
import MediaPlayer
import CoreBluetooth

let timeZone = TimeZone.current
let timeZoneName = timeZone.identifier

@objc public protocol SenseOSDelegate {
    func onFailure(message: String)
    func onSuccess(data: String)
}

let sense = SenseOS()
public class SenseOS: NSObject{
    private static var senseConfig: SenseOSConfig?
    static var delegate: SenseOSDelegate?
   
    static var lastLocation: CLLocation?
    static var geoCode: [String: Any]?
    private var locationManager: LocationManager?
    
    public func initializeLocationManager() {
        if #available(iOS 13.0, *) {
            locationManager = LocationManager()
            locationManager?.startUpdatingLocation()
        }
    }
    
    public static func initSDK(senseConfig: SenseOSConfig?, withDelegate: SenseOSDelegate?) {
        self.delegate = withDelegate
        self.senseConfig = senseConfig
        
        let alloLocation = senseConfig?.allowGeoLocation
        if (alloLocation == true){
            sense.initializeLocationManager()
        }
    }
    
   
    
    public static func getSenseDetails(withDelegate: SenseOSDelegate?) {
            getNetworkName { networkType in
                self.delegate = withDelegate

                let senseID = KeychainHelper.shared.getOrCreateSenseID()
                
                let data: [String: Any] = [
                    "device_details": [
                        "version": "0.0.1",
                        "zone": DeviceDetail().getZone(),
                        "device": DeviceDetail().getDeviceDetail(),
                        "language": getLanguageInfo() as Any,
                        "location": getLocationInfo() ?? "",
                        "screen": DeviceDetail().getScreen(),
                        "media": DeviceDetail().getMedia(),
                        "battery": DeviceDetail().getBattery(),
                        "connection": DeviceDetail().getConnection(networkType: networkType),
                    ],
                    "senseID": senseID,
                ]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    withDelegate?.onSuccess(data: jsonString)
                } else {
                    withDelegate?.onFailure(message: "Failed to serialize data")
                }
            }
        }
    }


public class DeviceDetail {
    
    public func getDeviceDetail() -> Dictionary<String, Any>{
        let device = UIDevice.current
        
        return [
            "deviceId" : UIDevice.current.identifierForVendor?.uuidString ?? "",
            "platform" : device.systemName,
            "isRealDevice" : !UIDevice.isSimulator,
            "touchSupport" : true,
            "deviceMemory" : "\(ProcessInfo.processInfo.physicalMemory/(1024*1024)) mb",
            "os" : device.systemName + " \(device.systemVersion)",
            "deviceTypes" : checkDeviceType() ?? "",
            "board" : "Apple",
            "brand" :"Apple" ,
            "manufacturer" : "Apple",
            "model" : device.name,
            "type" : "user",
            "localIpAddress" : getIPAddress(),
            "dataEnabled" : isDataEnabled(),
            "networkType" : getNetworkType(),
            "dataRoaming" : isDataRoamingEnabled(),
            "memoryInformation" : getMemoryInfo() ?? "",
            "kernelVersion" : getKernelVersion(),
            "countryInfo" : getCountryInfo() ?? "",
            "systemStorage" : ["total":totalDiskSpace(), "used":usedDiskSpace(), "free": freeDiskSpace()],
            "deviceArchitecture" : getDeviceArchitecture() ?? "",
            "kernelName" : getKernelName() ?? "",
            "networkConfig" : getNetworkConfiguration(),
            "biometricEnabled" : isBiometricsEnabled(),
            "passcodeEnabled" : isPasscodeEnabled(),
            "isAudioMuted" : isAudioMuted(),
            "cpuCount" : getCPUCount(),
            "cpuType" : getCPUType() ?? "",
            "isOnCall" : isOnCall(),
            "cpuSpeed" : getCPUSpeed() ?? "",
            "usbDebuggingStatus" : isDebuggerAttached(),
            "deviceADID" : getDeviceAdID() ?? "",
            "cloudContainer" : isICloudContainerAvailable(),
            "systemUptime" : getSystemUptime(),
            "isiOSAppOnMac": isPossiblyIOSAppOnMac(),
            "proximitySensor": isProximitySensorAvailable(),
            "lastBootTime": getBootTimeInfo(),
            "sessionID": sessionID(),
            "accessaryCount": accessaryCount(),
            "isMultitaskingSupported": UIDevice.current.isMultitaskingSupported,
            "accessibilityEnabled": UIAccessibility.isVoiceOverRunning,
            "developerModeEnabled": isDeveloperModeEnabled(),
            "deviceHash": UIDevice.current.identifierForVendor?.uuidString.hashValue ?? "",
            "screenBeingMirrored": ScreenMirroringDetector.isScreenMirroringActive(),
            "uuid": UUID().uuidString,
            "model_name": getDeviceName(),
        ]
    }
    
    public func getScreen() -> Dictionary<String, Any> {
        let screenWidth = UIScreen.main.bounds.width;
        let screenHeight = UIScreen.main.bounds.height;
        let scale = UIScreen.main.scale
        return [
            "screenBrightness" : Float(UIScreen.main.brightness),
            "displayResolution" :"\(screenWidth) x \(screenHeight)",
            "colorDepth" : getScreenColorDepth(),
            "screenWidth" : screenWidth,
            "screenHeight" : screenHeight,
            "screenPixelRatio" : scale,
            "screenSize" : screenSize() ?? "",
            "screenOrientation" : getDeviceOrientation()
        ]
    }
    public func getMedia() -> Dictionary<String, Any> {
        return [
            "audioHardware" : ["hasSpeakers" :true],
            "microPhoneHardware" : ["hasMicrophone" : true],
            "videoHardware" : ["hasWebCam" : true],
        ]
    }
    public func getBattery() -> Dictionary<String, Any> {
        return [
            "batteryTemperature": UIDevice.current.batteryLevel,
            "deviceCharging" : isCharging(),
            "batteryLevel" : getBatteryLevel(),
        ]
    }
    public func getZone() -> Dictionary<String, Any> {
        let currentTimeInMilliseconds = Date().timeIntervalSince1970 * 1000
        let currentTimeRounded = Int(currentTimeInMilliseconds.rounded())
        return [
            "timestamp": currentTimeRounded,
            "timezone": timeZoneName,
            "timezoneCountry": getCurrentTimeZoneCountry() ?? ""
        ]
    }
    public func getConnection(networkType:Any) -> Dictionary<String, Any> {
        return [
            "effectiveType" : getNetwork(),
            "type" : networkType
        ]
    }
}


