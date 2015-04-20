//
//  MediaPickerController.swift
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/3/27.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

import UIKit



@objc protocol MediaPickerControllerDelegate
{
    func mediaPickerControllerFinishedWithInfo(info:[NSObject:AnyObject])
    func mediaPickerControllerDidCancel()
}

class MediaPickerController: NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    /*Description:Class function to init a Media picker
      Parameter:
             viewController: using to show MediaPicker
             mediaType:   use photo or video and take photo
    */
    class func mediaPickerWithViewController(viewController:UIViewController!,mediaType:MediaType)->MediaPickerController
    {
        
          let mediaPickerController = MediaPickerController()
          mediaPickerController.viewController = viewController
          mediaPickerController.mediaType = mediaType
          return mediaPickerController
    }
    
    var viewController : UIViewController! = nil
    var mediaType : MediaType! = nil
    var imagePickerController:UIImagePickerController! = nil
    var delegate : MediaPickerControllerDelegate! = nil
    
    func openMediaPicker()->Void
    {
      
        imagePickerController = UIImagePickerController()
        if(mediaType == MediaType.MediaPhoto){
          imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }else if(mediaType == MediaType.MediaTakePhoto||mediaType == MediaType.MediaVideo){
          imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        }
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(imagePickerController.sourceType)!
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        viewController.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        if(picker.sourceType == UIImagePickerControllerSourceType.Camera){
            if(picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureMode.Photo){
                mediaType = MediaType.MediaTakePhoto
            }else if(picker.cameraCaptureMode == UIImagePickerControllerCameraCaptureMode.Video){
                mediaType = MediaType.MediaVideo
            }
        }else {
            var str = info["UIImagePickerControllerMediaType"] as String
            if(str == "public.movie"){
                mediaType = MediaType.MediaVideo
            }else {
                mediaType = MediaType.MediaPhoto
            }
        }
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        if (self.delegate != nil){
            self.delegate.mediaPickerControllerFinishedWithInfo(info)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
          
            if (self.delegate != nil){
               self.delegate.mediaPickerControllerDidCancel()
            }
        })
    }
}