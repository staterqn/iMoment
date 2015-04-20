//
//  MoviePlayerView.m
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/1.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import "MoviePlayerView.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>

#define BottomViewHeight 44

typedef NS_ENUM(NSInteger, GestureType){
    GestureTypeOfNone = 0,
    GestureTypeOfVolume,
    GestureTypeOfBrightness,
    GestureTypeOfProgress,
};
//记住播放进度相关的数据库操作类
@interface DatabaseManager : NSObject
+ (id)defaultDatabaseManager;
- (void)addPlayRecordWithIdentifier:(NSString *)identifier progress:(CGFloat)progress;
- (CGFloat)getProgressByIdentifier:(NSString *)identifier;
@end

@interface MoviePlayerView ()

@property (nonatomic,assign)BOOL isPlaying;
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)NSMutableArray *itemTimeList;
@property (nonatomic)CGFloat movieLength;
@property (nonatomic)NSInteger currentPlayingItem;
@property (nonatomic,strong)MBProgressHUD *progressHUD;
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UIView *superView;
@property (nonatomic,strong)UIView *bottomView;

@property (nonatomic,weak)id timeObserver;
@end

@implementation MoviePlayerView

- (id)initNetworkMoviePlayerViewControllerWithURL:(NSURL *)url movieTitle:(NSString *)movieTitle superView:(UIView *)view{
    self = [super init];
    if (self) {
        _superView = view;
        _isPlaying = YES;
        _movieURL = url;
        _movieURLList = @[url];
        _movieTitle = movieTitle;
        _itemTimeList = [[NSMutableArray alloc]initWithCapacity:5];
        _mode = MoviePlayerViewControllerModeNetwork;
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
    }
    return self;
}
- (id)initLocalMoviePlayerViewControllerWithURL:(NSURL *)url movieTitle:(NSString *)movieTitle superView:(UIView *)view{
    self = [super init];
    if (self) {
        _superView = view;
        _isPlaying = YES;
        _movieURL = url;
        _movieURLList = @[url];
        _movieTitle = movieTitle;
        _itemTimeList = [[NSMutableArray alloc]initWithCapacity:5];
        _mode = MoviePlayerViewControllerModeLocal;
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
    }
    return self;
}
-(void)prepareToPlay
{
    [self createBottomView];
    [self createAvPlayer];
    [self addGestureRecognizer];
    [self addNotification];
    [self bringSubviewToFront:_bottomView];
}
-(void)addGestureRecognizer
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecongnized:)];
    [self addGestureRecognizer:tapGesture];
}
-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
- (void)createAvPlayer{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = self.layer.bounds;
    __block CMTime totalTime = CMTimeMake(0, 0);
    [_movieURLList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *url = (NSURL *)obj;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        totalTime.value += playerItem.asset.duration.value;
        totalTime.timescale = playerItem.asset.duration.timescale;
        [_itemTimeList addObject:[NSNumber numberWithDouble:((double)playerItem.asset.duration.value/totalTime.timescale)]];
    }];
    _movieLength = (CGFloat)totalTime.value/totalTime.timescale;
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:(NSURL *)_movieURLList[0]]];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layer addSublayer:playerLayer];
    [_player play];
    
    _currentPlayingItem = 0;
    
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    //这里为了避免timer双重引用引起的内存泄漏
    __weak typeof(_player) player_ = _player;
    __weak typeof(_itemTimeList) itemTimeList_ = _itemTimeList;
    typeof(_movieLength) *movieLength_ = &_movieLength;
    typeof(_currentPlayingItem) *currentPlayingItem_ = &_currentPlayingItem;
    
    UILabel *currentLable = [[UILabel alloc]initWithFrame:CGRectMake(0 ,0, 63, 20)];
    currentLable.center = CGPointMake(63/2.0, BottomViewHeight/2.0);
    currentLable.font = [UIFont systemFontOfSize:13];
    currentLable.textColor = [UIColor whiteColor];
    currentLable.backgroundColor = [UIColor clearColor];
    currentLable.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:currentLable];
    
    UILabel *emainingTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 63, 20)];
    emainingTimeLable.center = CGPointMake(_bottomView.bounds.size.width-63/2.0, BottomViewHeight/2.0);
    emainingTimeLable.font = [UIFont systemFontOfSize:13];
    emainingTimeLable.textColor = [UIColor whiteColor];
    emainingTimeLable.backgroundColor = [UIColor clearColor];
    emainingTimeLable.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:emainingTimeLable];

    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time){

            CMTime currentTime = player_.currentItem.currentTime;
            double currentPlayTime = (double)currentTime.value/currentTime.timescale;
            NSInteger currentTemp = *currentPlayingItem_;
            
            while (currentTemp > 0) {
                currentPlayTime += [(NSNumber *)itemTimeList_[currentTemp-1] doubleValue];
                --currentTemp;
            }
            //转成秒数
            CGFloat remainingTime = (*movieLength_) - currentPlayTime;
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentPlayTime];
            NSDate *remainingDate = [NSDate dateWithTimeIntervalSince1970:remainingTime];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            [formatter setDateFormat:(currentPlayTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
            NSString *currentTimeStr = [formatter stringFromDate:currentDate];
            [formatter setDateFormat:(remainingTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
            NSString *remainingTimeStr = [NSString stringWithFormat:@"-%@",[formatter stringFromDate:remainingDate]];
            currentLable.text = currentTimeStr;
            emainingTimeLable.text = remainingTimeStr;
    }];
    _progressHUD = [[MBProgressHUD alloc]initWithView:self];
    [self addSubview:_progressHUD];
    [_progressHUD show:YES];
}
-(void)createBottomView
{
    CGRect bounds = self.bounds;
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bounds.size.height-BottomViewHeight, bounds.size.width, BottomViewHeight)];
    _bottomView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
    [self addSubview:_bottomView];
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40, 40)];
    _playBtn.center = CGPointMake(bounds.size.width/2.0, BottomViewHeight/2.0);
    [_playBtn setImage:[UIImage imageNamed:@"pause_nor.png"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(pauseBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            [_progressHUD hide:YES];
        }
    }
}

- (void)tapGestureRecongnized:(UITapGestureRecognizer *)sender
{
    if(_bottomView.frame.origin.y >= self.frame.size.height){
       [UIView animateWithDuration:0.25 animations:^{
           _bottomView.center = CGPointMake(_bottomView.center.x, self.frame.size.height-BottomViewHeight/2.0);
       }];
    }else if(_bottomView.frame.origin.y <= self.frame.size.height - BottomViewHeight) {
        [self hidenControlBar];
    }
}

- (void)hidenControlBar{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect bottomFrame = _bottomView.frame;
        bottomFrame.origin.y = self.frame.size.height;
        _bottomView.frame = bottomFrame;
    }];
}

#pragma mark - action
/*
 *程序活动的动作
 */
- (void)becomeActive{
   
    if(_isPlaying){
        [self play];
    }else {
        [self pause];
    }
}
/*
 *程序不活动的动作
 */
- (void)resignActive{

    [self pause];
}
//播放/暂停
- (void)pauseBtnClick
{
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
        
        [self play];
    }else{
        [self pause];
    }
}
-(void)play
{
    [_player play];
    [_playBtn setImage:[UIImage imageNamed:@"pause_nor.png"] forState:UIControlStateNormal];
}
-(void)pause
{
    [_player pause];
    [_playBtn setImage:[UIImage imageNamed:@"play_nor.png"] forState:UIControlStateNormal];
}
//视频播放到结尾
- (void)playerItemDidReachEnd:(NSNotification *)notification{
    if (_currentPlayingItem+1 == _movieURLList.count) {
        [_player.currentItem removeObserver:self forKeyPath:@"status"];
        [self pauseBtnClick];
        [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:_movieURLList[_currentPlayingItem]]];
        [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    }else{
        ++_currentPlayingItem;
        [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:_movieURLList[_currentPlayingItem]]];
        if (_isPlaying == YES){
            [_player play];
        }
    }
}
//返回事件
- (void)popView
{
    [_player removeTimeObserver:_timeObserver];
    [_player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_player replaceCurrentItemWithPlayerItem:nil];//自动移除 observer
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.timeObserver = nil;
        self.player = nil;
        if ([_delegate respondsToSelector:@selector(moviePlayingFinished)]) {
            [_delegate moviePlayingFinished];
        }
    }];
}
-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self popView];
}
@end
