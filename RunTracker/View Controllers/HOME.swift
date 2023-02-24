

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var inscributton: UIButton!
    @IBOutlet weak var connexbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
      
         setUpElements()
                                 }
    
func setUpElements() {

    Utilities.styleFilledButton(inscributton)
    Utilities.styleFilledButton(connexbutton)
                                 }
}
