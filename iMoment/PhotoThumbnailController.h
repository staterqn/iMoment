//
//  PhotoThumbnailController.h
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/2.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol PhotoThumbnailControllerDelegate <NSObject>

-(void)photoPickerCompleted:(NSMutableArray *)photos;

@end

@interface PhotoThumbnailController : UIViewController

@property (nonatomic,weak)  id<PhotoThumbnailControllerDelegate> delegate;

-(instancetype)initWithDataSource:(NSMutableArray *)dataSource title:(NSString *)title;

@end


@interface UICollectionViewCellPhoto : UICollectionViewCell

@property (nonatomic, strong)    UIImageView *photo;
@property (nonatomic,strong)     UIView *maskView;

-(void)updateSelectStatus:(BOOL)selected;

@end