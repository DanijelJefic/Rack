

import UIKit

struct TutorialData {
  var title: String
}

class TutorialPageContentController: UIViewController {
  
  var data: TutorialData? 
  @IBOutlet weak var detailLabel: UILabel!
  @IBOutlet weak var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.detailLabel.text = data?.title
  }
  
}
