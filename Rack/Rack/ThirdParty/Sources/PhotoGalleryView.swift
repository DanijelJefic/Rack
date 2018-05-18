//
//  PhotoGalleryView.swift
//  Rack
//
//  Created by  on 30/12/17.
//  Copyright © 2017 Hyperlink. All rights reserved.
//

import UIKit
import Photos

extension PhotoGalleryView:UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}
extension PhotoGalleryView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
       
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "Cell")
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            
            cell.textLabel?.font = UIFont.applyRegular(fontSize: 15.0)
            cell.detailTextLabel?.textColor = UIColor.black.withAlphaComponent(0.2)
            cell.detailTextLabel?.font = UIFont.applyRegular(fontSize: 13.0)
            
            let imageView = UIImageView()
            imageView.clipsToBounds = true
            imageView.tag = 10001
            imageView.frame = CGRect(x:14.0,y:(70.0-50.0)/2.0,width:50.0,height:50.0)
            cell.contentView.addSubview(imageView)
            
            let titleLabel = UILabel()
            titleLabel.tag = 10002
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont.applyRegular(fontSize: 15.0)
            titleLabel.frame = CGRect(x:imageView.frame.origin.x+imageView.frame.size.width+10.0,y:(70.0)/2.0-16.0,width:tableView.frame.size.width-(imageView.frame.origin.x+imageView.frame.size.width+20.0),height:16.0)
            cell.contentView.addSubview(titleLabel)
            
            
            let countLabel = UILabel()
            countLabel.tag = 10003
            countLabel.textColor = UIColor.black.withAlphaComponent(0.2)
            countLabel.font = UIFont.applyRegular(fontSize: 12.0)
            countLabel.frame = CGRect(x:imageView.frame.origin.x+imageView.frame.size.width+10.0,y:(70.0)/2.0+6.0,width:tableView.frame.size.width-(imageView.frame.origin.x+imageView.frame.size.width+20.0),height:16.0)
            cell.contentView.addSubview(countLabel)
            
            let divider = UIView()
            divider.frame = CGRect(x:14.0,y:69.0,width:tableView.frame.size.width-28.0,height:0.6)
            divider.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            cell.contentView.addSubview(divider)
        }
       
        let imageView:UIImageView = cell.viewWithTag(10001) as! UIImageView
        let titleLabel:UILabel = cell.viewWithTag(10002) as! UILabel
         let countLabel:UILabel = cell.viewWithTag(10003) as! UILabel
        
        let album = albums[indexPath.row]
        titleLabel.text = album.name
        countLabel.text = String(album.count)
     
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named:"camera_placeholder")
        imageView.clipsToBounds = true
        
        if album.asset != nil {
        DispatchQueue.global(qos: .default).async(execute: {
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: album.asset!,
                                            targetSize: CGSize(width: (album.asset?.pixelWidth)!, height: (album.asset?.pixelHeight)!),
                                            contentMode: .aspectFill,
                                            options: options) {
                                                result, info in
                                                
                                                DispatchQueue.main.async(execute: {
   
                                                    imageView.image = result
                                                    imageView.contentMode = .scaleAspectFill
     
                                                })
            }
        })
        }
        
        return cell
    }
}
class PhotoGalleryView: UIView {
    fileprivate var imageManager: PHCachingImageManager?
    var albums:[AlbumModel] = [AlbumModel]()
    typealias CallBack = (AlbumModel!)->Void
    var callBack:CallBack!
   // var album:AlbumModel! = nil
    var tableView:UITableView! = nil
    
    
     init(frame: CGRect,album:AlbumModel? ) {
        super.init(frame: frame)
        
        self.imageManager = PHCachingImageManager()
        
        self.backgroundColor = UIColor.white
        
        tableView =  UITableView.init(frame: self.bounds, style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        tableView.dataSource = self
        self.addSubview(tableView)
        
        if album != nil {
          //  albums.append(album!)
        }
        self.listAlbums()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func listAlbums() {
        
        
        let options = PHFetchOptions()
     
       let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: options)
        
        let topLevelfetchOptions = PHFetchOptions()
        
       // let topLevelUserCollections = PHAssetCollection.fetchTopLevelUserCollections(with: topLevelfetchOptions)
        
        smartAlbums.enumerateObjects({ (collection, start, stop) in
            if collection is PHCollection {
              
                if (collection.localizedTitle == "Slo-mo" || collection.localizedTitle == "Bursts" || collection.localizedTitle == "Videos" || collection.localizedTitle == "Hidden" || collection.localizedTitle == "Time-lapse" || collection.localizedTitle == "Live Photos" || collection.localizedTitle == "Animated" || collection.localizedTitle == "Long Exposure")  {
                    
                }else{
                    let obj:PHCollection = collection
                    let assets = PHAsset.fetchAssets(in: obj as! PHAssetCollection, options: nil)
                    var asset:PHAsset! = nil
                    if assets.count > 0 {
                        asset = assets.lastObject
                    }
                    let newAlbum = AlbumModel(name: collection.localizedTitle!, count: assets.count, collection:collection,asset:asset)
                    self.albums.append(newAlbum)
                }
                
              
            }})

      
        
       let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: options)
            userAlbums.enumerateObjects({ (collection, start, stop) in
                if collection is PHAssetCollection {
                    let obj:PHAssetCollection = collection
    
                    if obj.estimatedAssetCount > 0 {

                        
                        let assets = PHAsset.fetchAssets(in: obj, options: nil)
                        var asset:PHAsset! = nil
                        if assets.count > 0 {
                            asset = assets.lastObject
                        }
                        let newAlbum = AlbumModel(name: collection.localizedTitle!, count: obj.estimatedAssetCount, collection:collection,asset:asset)
                        self.albums.append(newAlbum)
                    }
    
                }else {
                    let obj:PHCollection = collection
                    let assets = PHAsset.fetchAssets(in: obj as! PHAssetCollection, options: nil)
                 
                    var asset:PHAsset! = nil
                    if assets.count > 0 {
                        asset = assets.lastObject
                    }
                    let newAlbum = AlbumModel(name: collection.localizedTitle!, count: assets.count, collection:collection,asset:asset)
                    self.albums.append(newAlbum)
                    
                }
            })
        
       self.tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.callBack != nil  {
            //print(albums)
             //print(albums[indexPath.row])
            self.callBack(albums[indexPath.row])
        }
    }
    

}

class AlbumModel {
    let name:String
    let count:Int
    let collection:Any?
    let asset:PHAsset?
    init(name:String, count:Int, collection:Any?, asset:PHAsset?) {
        self.name = name
        self.count = count
        self.collection = collection
        self.asset = asset
    }
}
