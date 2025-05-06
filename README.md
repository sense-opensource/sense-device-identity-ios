<h1>Sense Device Identity iOS</h1>

<p width="100%">
    <a href="https://github.com/sense-opensource/sense-device-identity-ios/blob/main/LICENSE">
        <img width="9%" src="https://custom-icon-badges.demolab.com/github/license/denvercoder1/custom-icon-badges?logo=law">
    </a>
    <img width="12.6%" src="https://badge-generator.vercel.app/api?icon=Github&label=Last%20Commit&status=May&color=6941C6"/> 
    <a href="https://discord.gg/hzNHTpwt">
        <img width="10%" src="https://badge-generator.vercel.app/api?icon=Discord&label=Discord&status=Live&color=6941C6"> 
    </a>
</p>

<h2>Welcome to Sense’s open source repository</h2>

<p width="100%">  
<img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Fork-orange.svg?logo=fork"> <img width="4.5%" src="https://custom-icon-badges.demolab.com/badge/Star-yellow.svg?logo=star"> <img width="6.5%" src="https://custom-icon-badges.demolab.com/badge/Commit-green.svg?logo=git-commit&logoColor=fff"> 
</p>

### 🖱️ Device Identity

![IP Address](https://img.shields.io/badge/IP_Address-blue)
![Location](https://img.shields.io/badge/Location-green)
![Screen Resolution](https://img.shields.io/badge/Screen_Resolution-orange)
![Connection](https://img.shields.io/badge/Connection-purple)
![Sense ID](https://img.shields.io/badge/Sense_ID-blue)
![Media](https://img.shields.io/badge/Media-green)
![Call Status](https://img.shields.io/badge/Call_Status-orange)
![Location IP Address](https://img.shields.io/badge/Location_IP_Address-purple)
![Memory Information](https://img.shields.io/badge/Memory_Information-blue)
![Proximity Sensor Data](https://img.shields.io/badge/Proximity_Sensor_Data-green)
![System Storage](https://img.shields.io/badge/System_Storage-orange)
![Battery Informations](https://img.shields.io/badge/Battery_Informations-purple)
![Device Informations](https://img.shields.io/badge/Device_Informations-green)


<h3>Getting started with Sense </h3>

<h3>Sense - iOS SDK</h3>

Sense is a device intelligence and identification tool. This tool collects a comprehensive set of attributes unique to a device or browser, forming an identity that will help businesses.
Requirements


<h3>Requirements</h3>

* OS 12.0 or above
* Swift version 5.0 and above

Note: If the application does not have the listed permissions, the values collected using those permissions will be ignored. To provide a valid device details, we recommend employing as much permission as possible based on your use-case.

Step 1 - Import SDK

```
 import SenseOS
````
Step 2 - Add Delegate Method

Add the delegate method in your Controller Class file
````
SenseOSDelegate
````

Step 3 - Get Device Details

Use the line below to invoke any button action or ViewDidLoad to get the DeviceDetails.

```
SenseOS.getSenseDetails(withDelegate: self)
let config = SenseOSConfig()
Sense.initSDK(senseConfig: config, withDelegate: self)
```

Step 4 - Location Permission (Optional)

You have to add this permission in Info.plist to get Device Location Information.

```
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>This app needs access to your location to provide location-based services.</string>
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>Location access is required for enhanced app functionality.</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>Require to get user location</string>

```

Step 5 - Implement Delegate Method

Set and Implement our Delegate method to receive the Callback details

```
 extension ViewController: SenseOSDelegate{
    func onFailure(message: String) {
        // Failure Callback.
    }
    func onSuccess(data: [String : Any]) {
        // Success Callback
    }
}

```

Sample Program

Here you can find the demonstration to do the integration.

```
import UIKit
import SenseOS

class SenseOSController: UIViewController, SenseOSDelegate {

  override func viewDidLoad() {
      super.viewDidLoad()
	SenseOS.getSenseDetails(withDelegate: self)
	Sense.initSDK(senseConfig: SenseOSConfig, withDelegate: self)
      
  }

  @objc func onSuccess(data: String) {     
      // Handle success callback
  }
  @objc func onFailure(message: String) {
      // Handle failure callback
  }
}

``` 

<h4>Plug and play, in just 4 steps</h3>  

1️⃣ Visit the GitHub Repository</br>
2️⃣ Download or Clone the Repository. Use the GitHub interface to download the ZIP file, or run.</br>
3️⃣ Run the Installer / Setup Script. Follow the setup instructions provided below.</br>
4️⃣ Start Testing. Once installed, begin testing and validating the accuracy of the metrics you're interested in.</br>

<h4>With Sense, you can</h4>  

✅ Predict user intent : Identify the good from the bad visitors with precision  
✅ Create user identities : Tokenise events with a particular user and device  
✅ Custom risk signals : Developer specific scripts that perform unique functions  
✅ Protect against Identity spoofing : Prevent users from impersonation  
✅ Stop device or browser manipulation : Detect user behaviour anomalies 

<h4>Resources</h4> 

MIT license : 

Sense OS is available under the <a href="https://github.com/sense-opensource/sense-device-identity-ios/blob/main/LICENSE"> MIT license </a>

#### Contributors code of conduct : 

Thank you for your interest in contributing to this project! We welcome all contributions and are excited to have you join our community. Please read these <a href="https://github.com/sense-opensource/sense-device-identity-ios/blob/main/code_of_conduct.md"> code of conduct </a> to ensure a smooth collaboration.

#### Where you can get support :     
![Gmail](https://img.shields.io/badge/Gmail-D14836?logo=gmail&logoColor=white)       product@getsense.co 

Public Support:

For questions, bug reports, or feature requests, please use the Issues and Discussions sections on our repository. This helps the entire community benefit from shared knowledge and solutions.

Community Chat:

Join our Discord server (link) to connect with other developers, ask questions in real-time, and share your feedback on Sense.

Interested in contributing to Sense?

Please review our <a href="https://github.com/sense-opensource/sense-device-identity-ios/blob/main/CONTRIBUTING.md"> Contribution Guidelines </a> to learn how to get started, submit pull requests, or run the project locally. We encourage you to read these guidelines carefully before making any contributions. Your input helps us make Sense better for everyone!
