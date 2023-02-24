import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class Profil: UIViewController {
 
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet var poids: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var taille: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var ref: DatabaseReference!


    override func viewDidLoad() {
     profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
      ref = Database.database().reference()

        let uid = Auth.auth().currentUser?.uid
      Database.database().reference().child("users").child(uid!).child("profil").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
              self.name.text = dictionary["nom"] as? String ?? ""
              let l = dictionary["poids"] as? String ?? ""
              self.poids.text = "Peso: \(l) kg"
              let b = dictionary["age"] as? String ?? ""
              self.age.text = "Edad: \(b) años"
              let d = dictionary["taille"] as? String ?? ""
              self.taille.text = "Altura: \(d) cm"
              let st = dictionary["profileimg"] as? String ?? ""
              let url = URL(string: st)
              self.profileImageView.downloadImage(from: url!)
          }
  })
      }

}

    
    extension UIImageView {
       func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
          URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
       }
       func downloadImage(from url: URL) {
          getData(from: url) {
             data, response, error in
             guard let data = data, error == nil else {
                return
             }
             DispatchQueue.main.async() {
                self.image = UIImage(data: data)
             }
          }
       }
    }

    
    
    
    


