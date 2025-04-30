

import UIKit
import SenseOS

class DeviceIdentityController: UIViewController, SenseOSDelegate {
  

    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var lblSenseID: UILabel!
    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var viewDetails: UIView!
    @IBOutlet weak var viewSenseInfo: UIView!
    @IBOutlet weak var viewDeviceID: UIView!
    @IBOutlet weak var viewDeviceDetails: UIView!
    @IBOutlet weak var viewJson: UIView!
    @IBOutlet weak var viewJsonDetails: UIView!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewConstantHeightOutlet: NSLayoutConstraint!
    @IBOutlet weak var textViewConstantHeightOutlet: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SenseOS.getSenseDetails(withDelegate: self)
        
        viewSenseInfo.applyBorderAndShadow(borderWidth: 0.3, borderColor: UIColor.lightGray, cornerRadius: 10)
        viewDeviceDetails.applyBorderAndShadow(borderWidth: 0.3, borderColor: UIColor.lightGray, cornerRadius: 10)
        viewJson.roundCornersWithBorder(
            corners: [.topLeft, .topRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
        viewDetails.roundCornersWithBorder(
            corners: [.topLeft, .topRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
        viewJsonDetails.roundCornersWithBorder(
            corners: [.bottomLeft, .bottomRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
        viewDeviceID.roundCornersWithBorder(
            corners: [.bottomLeft, .bottomRight],radius: 10,borderColor: .lightGray,borderWidth: 0.5
        )
    }
    
    func onFailure(message: String) {
        DispatchQueue.main.async {
          
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func onSuccess(data: String) {
        
        let encodedString = "\(data)"
        let jsonStringWithLineNumbers = addLineNumbersToJson(jsonString: encodedString)
        self.jsonTextView.text = jsonStringWithLineNumbers
        
        if let jsonData = data.data(using: .utf8),
              let parsed = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let strDict = parsed["str"] as? [String: Any],
              let senseID = strDict["senseID"] as? String {
               self.lblSenseID.text = "\(senseID)"
           } else {
               self.lblSenseID.text = "Failed to load Sense ID"
           }
    }
    
    func addLineNumbersToJson(jsonString: String) -> String {
        let lines = jsonString.split(separator: "\n")
        let linesCountss = jsonString.split(separator: "\n").count
        var numberedLines: [String] = []
        
        let maxLineNumberWidth = String(lines.count).count
        
        for (index, line) in lines.enumerated() {
            let lineNumber = String(index + 1)
            let paddedLineNumber = lineNumber.padding(toLength: maxLineNumberWidth, withPad: " ", startingAt: 0)
            let numberedLine = "\(paddedLineNumber) \(line)"
            numberedLines.append(numberedLine)
        }
        
        let baseHeight: CGFloat = 50
        let lineHeight: CGFloat = 18.5
        let newHeight = baseHeight + CGFloat(linesCountss) * lineHeight
      //   let viewConstantHeight = CGFloat(textViewConstantHeightOutlet.constant)
      //  let totalConstant = viewConstantHeight + CGFloat(linesCountss)
        textViewConstantHeightOutlet.constant = newHeight
        viewConstantHeightOutlet.constant = newHeight + 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        return numberedLines.joined(separator: "\n")
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        print("hello")
            DispatchQueue.main.async {
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "SignupController") as! SignupController
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
