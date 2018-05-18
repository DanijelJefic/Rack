//
//  ImageVC.swift
//  TutorialDemo
//
//  Created by hyperlink on 07/10/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit

class ImageVC : UIViewController {
    //------------------------------------------------------
    
    //MARK:- Outlet
    
    @IBOutlet var imgView: UIImageView!
    
    //------------------------------------------------------
    
    //MARK:- Class variable
    
    var img : UIImage? = nil
    
    //------------------------------------------------------
    
    //MARK:- WS Methods
    
    //------------------------------------------------------
    
    //MARK:- Memory Management Method
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------------------------------
    
    //MARK:- Custom Methods
    
    func setUp() {
        imgView.image = img
    }
    
    //------------------------------------------------------
    
    //MARK:- Action Methods
    
    
    //------------------------------------------------------
    
    //MARK:- Delegate Methods
    
    //------------------------------------------------------
    
    //MARK:- UI View Life Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setUp()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
