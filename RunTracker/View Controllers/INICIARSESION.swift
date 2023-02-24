

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passsword: UITextField!
    @IBOutlet weak var inicbutton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()

    }
    func setUpElements() {
        
        errorLabel.alpha = 0
        
        Utilities.styleTextField(email)
        Utilities.styleTextField(passsword)
        Utilities.styleFilledButton(inicbutton)
        
    }
    
    @IBAction func inicbutton(_ sender: Any) {
              
              let emaill = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              let password = passsword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              
              Auth.auth().signIn(withEmail: emaill, password: password) { (result, error) in
                  
                  if error != nil {
                      self.errorLabel.text = error!.localizedDescription
                      self.errorLabel.alpha = 1
                  }
                  else {
                      
                      
                    let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabC") as! UITabBarController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                      appDelegate.window?.rootViewController = tabBarController

    }
    
        }}
}
