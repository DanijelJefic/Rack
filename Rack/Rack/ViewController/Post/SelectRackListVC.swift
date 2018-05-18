//
//  SelectRackVC.swift
//  Rack
//
//  Created by GS Bit Labs on 1/16/18.
//  Copyright © 2018 Hyperlink. All rights reserved.
//

import UIKit

class SelectRackListVC: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var btnCreateRackOutlet: UIButton!
    
    // Post View
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    var _tvCaptionText : String = ""
    var _shareType : PostShareType = .main
    var _dictFromParent : ItemModel? = nil
    var _imgView = UIImageView()
    var _hmc : GGHashtagMentionController = GGHashtagMentionController()
    var _imgPost = UIImage()
    typealias NewRackSelected = (String, UIImage)->Void
    var newRackSelected:NewRackSelected!
    
    typealias TVCaptionText = (String)->Void
    var tvCaptionText:TVCaptionText!
    
    var searchActive : Bool = false
    var filtered:[folderStructure] = []
    var arrayItemData       : [folderStructure] = []
    
    var headerCell: SelectRackHeaderCell? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        filtered = self.arrayItemData
        setupView()
        
    }
    
    func leftButtonClicked() {
        navigationController?.popViewController(animated: true)
    }
    
    func rightButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    
override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       _ = addBarButtons(btnLeft: BarButton(title: "Back"), btnRight: nil, title: "Upload")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        self.tvCaptionText(self.postTextView.text!)
    }
    
    func setupView() {
        
        postTextView.text = self._tvCaptionText
        postImageView.image = self._imgPost
        postTextView.inputAccessoryView = UIToolbar().addToolBar(self)
        _hmc = GGHashtagMentionController.init(textView: postTextView, delegate: self)
        
        if _shareType == .main && _dictFromParent != nil {
            postTextView.text = self._dictFromParent?.caption
        }
        
        postTextView.applyStyle(textFont: UIFont.applyRegular(fontSize: 13.0), textColor: AppColor.text)
        postTextView.delegate = self
        
    }
    
    @IBAction func btnCreateNewRack(_ sender: AnyObject) {
        let createNewRackVC:CreateNewRackVC = storyboard?.instantiateViewController(withIdentifier: "CreateNewRackVC") as! CreateNewRackVC
            createNewRackVC.image = self._imgPost
            createNewRackVC.newRackAdded = {(text) in
                
            let firstData = folderStructure.modelsFromLocalDictionary(rackname: text, image: self._imgPost )
            self.arrayItemData.append(contentsOf: firstData)
                
            self.filtered = self.arrayItemData
            self.tblView.reloadData()
        }
        
        self.navigationController?.pushViewController(createNewRackVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}



extension SelectRackListVC: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 83.0 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! SelectRackHeaderCell
        headerCell.barSearch.delegate = self
            
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96 * kHeightAspectRasio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderCell", for: indexPath) as! SelectRackListCell
        
        let objAtIndex = filtered[indexPath.row]
        cell.folderName.text = objAtIndex.name
        
        if objAtIndex.rackId.isEmpty {
            cell.imgView.image = objAtIndex.localImage
        }else{
            cell.imgView.setImageWithDownload(objAtIndex.thumbnail.url())
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! SelectRackListCell
        if let image = cell.imgView.image {
            DispatchQueue.main.async {
                self.newRackSelected(cell.folderName.text!, image)
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tblView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        self.filtered = searchText.isEmpty ? self.arrayItemData : self.arrayItemData.filter({(obj: folderStructure) -> Bool in
            let tmp: NSString = obj.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        //print(filtered)
        
        self.tblView.reloadData()
        searchBar.becomeFirstResponder()
        
    }
    
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
}

class SelectRackHeaderCell: UITableViewCell {
    
    @IBOutlet weak var barSearch: UISearchBar!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var constSearchBarHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
        
        // Search Bar Setup
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: AppColor.createReckText, NSFontAttributeName: UIFont.applyRegular(fontSize: 13.0)]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        let textFieldPlaceHolder = barSearch.value(forKey: "searchField") as? UITextField
        textFieldPlaceHolder?.font = UIFont.applyRegular(fontSize: 13.0)
        textFieldPlaceHolder?.attributedPlaceholder = attributedPlaceholder
//        barSearch.setPositionAdjustment(UIOffset.init(horizontal: barSearch.frame.size.width/2.0-50, vertical: 0), for: UISearchBarIcon.search)
        barSearch.returnKeyType = .done
        barSearch.tintColor = UIColor.colorFromHex(hex: kColorGray74)
        
    }
}

class SelectRackListCell: UITableViewCell, UITextViewDelegate {
    
    // Folder List Cell
    @IBOutlet weak var folderName: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = AppColor.primaryTheme
        self.contentView.backgroundColor = AppColor.primaryTheme
        folderName.applyStyle(labelFont: UIFont.applyRegular(fontSize: 16.0), labelColor: AppColor.text)
    }
    
}

extension SelectRackListVC: UITextViewDelegate {
    
    
    //MARK:- TextField Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newLength = textView.text.characters.count + text.characters.count - range.length
        
        if (range.location == 0 && text == " ") || (range.location == 0 && text == "\n") {
            return false
        }
        
        //Uncomment this line if you want to limit the caption
        /*if newLength <= 200 {
         
         } else {
         return false
         }*/
        
        /*if text == "@" {
         //print("mention")
         
         delegate?.didTap(tagType: TagType.tagPeople)
         
         } else if text == "#" {
         //print("hashtag")
         }*/
        
        return true
    }
}

//MARK:- SearchTagDelegate -



extension SelectRackListVC : SearchCaptionDelegate {
    
    func searchCaptionDelegateMethod(_ tagDetail: Any,tagType : TagType?) {
        let name = PeopleTagModel(fromJson: JSON(tagDetail)).name
        self.postTextView.text = "\(self.postTextView.text!)\(name!) "
    }
}

extension SelectRackListVC : GGHashtagMentionDelegate {
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onHashtagWithText text: String!, range: NSRange) {
        
    }
    
    func hashtagMentionController(_ hashtagMentionController: GGHashtagMentionController!, onMentionWithText text: String!, range: NSRange) {
        if text.characters.count > 0 {
            let vc = secondStoryBoard.instantiateViewController(withIdentifier: "SearchPeopleCaptionVC") as! SearchPeopleCaptionVC
            vc.imageTagType = TagType.tagPeople
            vc.delegate = self
            vc.searchBar.text = text
            
            vc.completion = {(_ tagUser: Any) -> Void in
                
                if let name = PeopleTagModel(fromJson: JSON(tagUser)).name {
                    self.postTextView.text = (self.postTextView.text as NSString?)?.replacingCharacters(in: range, with: name as String)
                    self.postTextView.text = self.postTextView.text + " "
                    self.postTextView.becomeFirstResponder()
                } else {
                    self.postTextView.text = (self.postTextView.text as NSString?)?.replacingCharacters(in: range, with: "")
                    self.postTextView.becomeFirstResponder()
                }
                
            }
            
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func hashtagMentionControllerDidFinishWord(_ hashtagMentionController: GGHashtagMentionController!) {
        
    }
}
