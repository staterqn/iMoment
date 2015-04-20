//
//  PhotoPlayerController.h
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/2.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPlayerView : UIView

-(instancetype)initWithPhotos:(NSMutableArray *)array;
-(void)show;
@end


@interface PhotoPlayerCell : UICollectionViewCell

@property (nonatomic, strong)    UIImageView *photo;

@end