

import UIKit
import FirebaseAuth
import Firebase

struct MyKeys {
  static let imagesFolder = "imagesFolder"
  static let imagesCollection = "imagesCollection"
  static let uid = "uid"
  static let imageUrl = "imageUrl"
}
class SignUpViewController: UIViewController {


    @IBOutlet weak var nom: UITextField!
    
    @IBOutlet weak var prenom: UITextField!
    
  @IBOutlet var stepper: UIStepper!
  @IBOutlet var age: UITextField!
    @IBOutlet var poids: UITextField!
    @IBOutlet var taille: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var regibutton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var ref: DatabaseReference!

    var imagePicker:UIImagePickerController!


    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
      let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
      profileImageView.isUserInteractionEnabled = true
      profileImageView.addGestureRecognizer(imageTap)
      profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
      profileImageView.clipsToBounds = true
      imagePicker = UIImagePickerController()
      imagePicker.allowsEditing = true
      imagePicker.sourceType = .photoLibrary
      imagePicker.delegate = self

    }
  
  @IBAction func stepper(_ sender: Any) {
        self.age.text = "\(Int(stepper.value))"
    

  }
  @objc func openImagePicker(_ sender:Any) {
      self.present(imagePicker, animated: true, completion: nil)
  }

    
    func setUpElements() {
    
        errorLabel.alpha = 0
    
        Utilities.styleTextField(nom)
        Utilities.styleTextField(prenom)
        Utilities.styleTextField(email)
        Utilities.styleTextField(pass)
        Utilities.styleTextField(poids)
        Utilities.styleTextField(taille)
        Utilities.styleTextField(age)
        Utilities.styleFilledButton(regibutton)
    }
    
  func showError(_ message:String) {
      
      errorLabel.text = message
      errorLabel.alpha = 1
  }
  func transitionToHome() {
      
     let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabC") as! UITabBarController
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.window?.rootViewController = tabBarController

      
  }

    func validateFields() -> String? {
        
        if nom.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            prenom.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            pass.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            taille.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            poids.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            age.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""

        {
            
            return "Por favor rellena todos los campos."
        }
        
        let cleanedPassword = pass.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            return "Asegúrese de que su contraseña tenga al menos 8 caracteres y un número."
        }
        
        return nil}
  
      @IBAction func signUpTapped(_ sender: Any) {
        
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
              

          let Name = nom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let pName = prenom.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let emaill = email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let password = pass.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let altura = taille.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let peso = poids.text!.trimmingCharacters(in: .whitespacesAndNewlines)
          let edad = age.text!.trimmingCharacters(in: .whitespacesAndNewlines)

          Auth.auth().createUser(withEmail: emaill, password: password) { (result, err) in
                
                if err != nil {
                    
                    self.showError("Error al crear usuario")
                }
                else {

                    self.ref = Database.database().reference()
                    let userID = Auth.auth().currentUser?.uid
                  
                    guard let image = self.profileImageView.image,
                    let data = image.jpegData(compressionQuality: 0.25) else {
                            return
                      }
                      
                      let imageName = UUID().uuidString
                      let imageReference = Storage.storage().reference().child(MyKeys.imagesFolder).child(imageName)
                      imageReference.putData(data, metadata: nil) { (metadata, err) in
                          if let err = err {
                              return
                          }
                          
                          imageReference.downloadURL(completion: { (url, err) in
                              if let err = err {
                                  return
                              }
                              
                              guard let url = url else {
                                  return
                              }
                            self.ref.child("users").child(userID!).child("profil").setValue(["nom": Name,"taille": altura,"poids": peso,"age": edad,"profileimg": url.absoluteString,"prenom": pName])
 
                            let dataReference = Firestore.firestore().collection(MyKeys.imagesCollection).document()
                              let documentUid = dataReference.documentID
                              
                            let urlString = url.absoluteString
                              let data = [
                                MyKeys.uid: documentUid,
                                MyKeys.imageUrl: urlString
                              ]
                              
                              dataReference.setData(data, completion: { (err) in
                                  if let err = err {
                                      return
                                  }
                                  
                                  UserDefaults.standard.set(documentUid, forKey: MyKeys.uid)
                                  self.profileImageView.image = UIImage()
                              })
                              
                          })
                      }
                  self.transitionToHome()
            }
        }
    }
}
  
}
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
 func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
 {
        
  if let pickedImage = info[.originalImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

