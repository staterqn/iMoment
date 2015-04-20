//
//  ViewController.swift
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/3/27.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

import UIKit
import MediaPlayer

enum MediaType {

    case  MediaPhoto
    case  MediaTakePhoto
    case  MediaVideo
    case  MediaText
}

class ViewController: UIViewController,MediaPickerControllerDelegate,PhotoThumbnailControllerDelegate{

    var vc : MediaPickerController! = nil
    var photoView : PhotoPlayerView! = nil
    var movie : MoviePlayerView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: CGRectMake(50, 100, 50, 50))
        btn.backgroundColor = UIColor.redColor()
        self.view.addSubview(btn)
        btn.setTitle("Video", forState: UIControlState.Normal)
        btn.addTarget(self, action: "openVideo", forControlEvents: UIControlEvents.TouchUpInside)
        
        let btn1 = UIButton(frame: CGRectMake(150, 100, 50, 50))
        btn1.backgroundColor = UIColor.redColor()
        self.view.addSubview(btn1)
        btn1.setTitle("Photo", forState: UIControlState.Normal)
        btn1.addTarget(self, action: "openPhoto", forControlEvents: UIControlEvents.TouchUpInside)
        
        let btn2 = UIButton(frame: CGRectMake(250, 100, 50, 50))
        btn2.backgroundColor = UIColor.redColor()
        self.view.addSubview(btn2)
        btn2.setTitle("Clear", forState: UIControlState.Normal)
        btn2.addTarget(self, action: "clear", forControlEvents: UIControlEvents.TouchUpInside)

    }


    func mediaPickerControllerFinishedWithInfo(info: [NSObject : AnyObject]) {

        if(vc.mediaType == MediaType.MediaVideo){
           self.showVideo(info)
        }else {
           self.showPhoto(info)
        }
    }
    func mediaPickerControllerDidCancel(){
        
    }
    func openVideo()->Void {
         vc = MediaPickerController.mediaPickerWithViewController(self, mediaType: MediaType.MediaVideo)
         vc.delegate = self
         vc.openMediaPicker()

       
    }
    
    func openPhoto(){
        
//        var t = PhotoThumbnailController()
//        t.delegate = self
//        self.presentViewController(t, animated: true, completion: nil)
//        vc = MediaPickerController.mediaPickerWithViewController(self, mediaType: MediaType.MediaPhoto)
//        vc.delegate = self
//        vc.openMediaPicker()
        
        var t = PhotoTableViewController()
        var n = UINavigationController(rootViewController: t)
        self.presentViewController(n, animated: true, completion: nil)
    }
    
    func showVideo(info: [NSObject : AnyObject])->Void{
        var url = info["UIImagePickerControllerMediaURL"] as NSURL
        movie = MoviePlayerView(localMoviePlayerViewControllerWithURL: url, movieTitle: "test", superView:self.view)
        movie.frame = CGRectMake(0, 0, self.view.bounds.size.width*0.8,self.view.bounds.size.width*0.6)
        movie.center = self.view.center;
        self.view.addSubview(movie)
        movie.prepareToPlay()
    }
    func showPhoto(info: [NSObject : AnyObject])->Void{
        var t = info["UIImagePickerControllerOriginalImage"] as UIImage
        var imageView = UIImageView(image:t)
        imageView.bounds = CGRectMake(0, 0,100, 100)
        imageView.center = self.view.center
        self.view.addSubview(imageView)
    }
    
    func video()->Void{
      
    }
    
    
    func photoPickerCompleted(array:NSMutableArray)->Void{
        
        var arrays : NSMutableArray! = NSMutableArray()
        for asset in array {
            var represention = asset.defaultRepresentation()!
            let ref = represention.fullScreenImage().takeUnretainedValue()
            var image = UIImage(CGImage:ref)!
            arrays.addObject(image)
        }
        photoView = PhotoPlayerView(photos: arrays)
        photoView.center = self.view.center
        photoView.bounds = CGRectMake(0, 0,self.view.bounds.size.width * 0.9 , self.view.bounds.size.width * 0.7)
        self.view.addSubview(photoView);
        photoView.show()
        
    }
    
    func clear()->Void{
      
        if(movie != nil){
           movie.removeFromSuperview()
            movie = nil
        }
        if(photoView != nil){
           photoView.removeFromSuperview()
            photoView = nil
        }
    }
}

