
//  File.swift
//  Rack
//  Created by saroj  on 29/01/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import Foundation
import Photos

typealias Success = (_ photos:[PHAsset])->Void
class ImageManager: NSObject {
    static let sharedInstance = ImageManager()
    var images      : PHFetchResult<PHAsset>?
    private var assets = [PHAsset]()
    private var success:Success? = nil
    func loadPhotos(success:Success!){
        self.success = success
        if (self.assets.count != 0){
            self.success!(self.assets)
        } else {
            loadAllPhotos()
        }
    }
    private func loadAllPhotos() {
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects({ (object, index, stop) -> Void in
            self.assets.append(object)
            if self.assets.count == fetchResult.count{ self.success!(self.assets) }
        })
    }
    
    static func imageFrom(asset:PHAsset, size:CGSize, success:@escaping (_ photo:UIImage)->Void){
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .opportunistic
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, attributes) in
            success(image!)
        })
    }
    
    
    
    
    public func getImages() -> PHFetchResult<PHAsset>{
        
         if images != nil && images!.count != 0{
            return images!
         }
         let assetfetch = PHFetchOptions()
         assetfetch.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
         images = PHAsset.fetchAssets(with: .image, options: nil)
         var phAssetArray : [PHAsset] = []
         for  i in 0..<images!.count{
             phAssetArray.append(images![i])
            if i > 50 {
                break
            }
         }
        DispatchQueue.main.async {
            let _options = PHImageRequestOptions()
            _options.deliveryMode = .fastFormat
            _options.isNetworkAccessAllowed = true
            _options.isSynchronous = false
            let imageManager = PHCachingImageManager()
            imageManager.stopCachingImagesForAllAssets()
            imageManager.startCachingImages(for: phAssetArray, targetSize: CGSize(width:100 , height: 100), contentMode: .aspectFill, options: _options)
            
        }
        return images!
        
    }
    
    public func initializeLibraryImages() -> PHFetchResult<PHAsset>{
        return images!
    }
    
}

func imagesManager() -> ImageManager {
    return ImageManager.sharedInstance
}
