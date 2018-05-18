
//  File.swift
//  Rack
//  Created by saroj  on 29/01/18.
//  Copyright © 2018 Hyperlink. All rights reserved.

import Foundation
import Photos

class ImageManager: NSObject {
    static let sharedInstance = ImageManager()
    var images      : PHFetchResult<PHAsset>?
    
    public func getImages() -> PHFetchResult<PHAsset>{
        
        if images != nil && images!.count != 0{
            return images!
        }
        
        
        images = PHAsset.fetchAssets(with: .image, options: nil)
        var phAssetArray : [PHAsset] = []
        for  i in 0..<images!.count{
         phAssetArray.append(images![i])
         }
         let _options = PHImageRequestOptions()
         _options.deliveryMode = .fastFormat
         _options.isNetworkAccessAllowed = true
         _options.isSynchronous = false
        let imageManager = PHCachingImageManager()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        imageManager.startCachingImages(for: phAssetArray, targetSize: CGSize(width:screenWidth , height: screenWidth), contentMode: .aspectFill, options: _options)
        
        return images!
        
        
    }
    public func initializeLibraryImages() -> PHFetchResult<PHAsset>{
        return images!
    }
 

}

func imagesManager() -> ImageManager {
    return ImageManager.sharedInstance
}
