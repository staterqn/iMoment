//
//  PhotoTableViewController.h
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/7.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoTableViewController : UITableViewController

@end


@interface PhotTableCell : UITableViewCell

@property (nonatomic,strong) UIImageView* leftImageView;
@property (nonatomic,strong) UIImageView* rightImageView;
@property (nonatomic,strong) UILabel    * textDescription;
@end