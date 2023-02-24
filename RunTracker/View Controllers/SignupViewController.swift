

import UIKit
import FirebaseAuth
import Firebase
class SignupViewController: UIViewController {

  
    @IBOutlet weak var nom: UITextField!
    
    @IBOutlet weak var prenom: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signup: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
      
      setUpElements()


    }
  func setUpElements() {
  
      // Hide the error label
      errorLabel.alpha = 0
  
      // Style the elements
      Utilities.styleTextField(nom)
      Utilities.styleTextField(prenom)
      Utilities.styleTextField(email)
      Utilities.styleTextField(password)
      Utilities.styleFilledButton(signup)
  }
    
  func validation() ->String? {
    if nom.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || prenom.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || password.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" { return "Por favor rellena todos los campos" }
    let cleanedPassword = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Asegúrese de que su contraseña tenga al menos 8 caracteres, contenga un carácter especial y un número."
        }
        
    return nil
    
  }
    @IBAction func inscritap(_ sender: Any) {
      let error = validation()
          
          if error != nil {
              
              // There's something wrong with the fields, show error message
              showError(error!)
          }
          else {
              
              // Create cleaned versions of the data
              let firstName = nom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              let lastName = prenom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              let emaill = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              let passwordd = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
              
              // Create the user
              Auth.auth().createUser(withEmail: emaill, password: passwordd) { (result, err) in
                  
                  // Check for errors
                  if err != nil {
                      
                      // There was an error creating the user
                      self.showError("Error creating user")
                  }
                  else {
                      
                      // User was created successfully, now store the first name and last name
                      let db = Firestore.firestore()
                      
                      db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                          
                          if error != nil {
                              // Show error message
                              self.showError("Error saving user data")
                          }
                      
                      // Transition to the home screen
                        self.transitionToHome()}
                  }
            }}}

    
 func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
func transitionToHome() {
       
  if #available(iOS 13.0, *) {
    let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
    // Fallback on earlier version
       
       view.window?.rootViewController = homeViewController
       view.window?.makeKeyAndVisible()
       
   }
    
    
}
    

}

