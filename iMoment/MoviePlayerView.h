//
//  MoviePlayerView
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/1.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol MoviePlayerViewDelegate <NSObject>
- (void)moviePlayingFinished;
@end

@protocol MoviePlayerViewControllerDataSource <NSObject>

//key of dictionary
#define KTitleOfMovieDictionary @"title"
#define KURLOfMovieDicTionary @"url"

@required
- (NSDictionary *)nextMovieURLAndTitleToTheCurrentMovie;
- (NSDictionary *)previousMovieURLAndTitleToTheCurrentMovie;
- (BOOL)isHaveNextMovie;
- (BOOL)isHavePreviousMovie;
@end

@interface MoviePlayerView : UIView

typedef enum {
    MoviePlayerViewControllerModeNetwork = 0,
    MoviePlayerViewControllerModeLocal
} MoviePlayerViewControllerMode;


@property (nonatomic,strong,readonly)NSURL *movieURL;
@property (nonatomic,strong,readonly)NSArray *movieURLList;
@property (readonly,nonatomic,copy)NSString *movieTitle;
@property (nonatomic, assign) id<MoviePlayerViewDelegate> delegate;
@property (nonatomic, assign) id<MoviePlayerViewControllerDataSource> datasource;
@property (nonatomic, assign) MoviePlayerViewControllerMode mode;

- (id)initNetworkMoviePlayerViewControllerWithURL:(NSURL *)url movieTitle:(NSString *)movieTitle superView:(UIView *)view;
- (id)initLocalMoviePlayerViewControllerWithURL:(NSURL *)url movieTitle:(NSString *)movieTitle superView:(UIView *)view;

- (void)prepareToPlay;

@end
