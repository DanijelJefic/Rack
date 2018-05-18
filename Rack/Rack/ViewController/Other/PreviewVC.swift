//
//  PreviewVC.swift
//  Rack
//
//  Created by hyperlink on 17/05/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController {

    //MARK:- Outlet
    @IBOutlet var imgView : UIImageView!
    //------------------------------------------------------
    
    //MARK:- Class Variable
    var image : URL!
    var imageURL : URL!
    //------------------------------------------------------
    
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Method
    
    func setUpView() {
//        imgView.sd_setImage(with: image)
        imgView.setImageWithDownload(image)
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
         self.navigationController?.customize()
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Method
    
    //------------------------------------------------------
    
    //MARK:- Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}
