//
//  PhotoPlayerController.m
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/2.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import "PhotoPlayerView.h"
#define PHOTO_IDENTIFIER @"PhotoPlayerCell"
@interface PhotoPlayerView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic,strong) UICollectionView *photosCollection;
@property (nonatomic,strong) UIScrollView *BGScrollView;
@end

@implementation PhotoPlayerView


-(instancetype)initWithPhotos:(NSMutableArray *)array
{
    if(self = [super initWithFrame:CGRectZero]){
        
        self.backgroundColor = [UIColor blackColor];
        self.photos = [NSMutableArray arrayWithArray:array];
        [array removeAllObjects];
        array = nil;
    }
    return self;
}

-(void)show
{
    UICollectionViewFlowLayout *layoutCollection = [[UICollectionViewFlowLayout alloc] init];
    layoutCollection.itemSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    layoutCollection.minimumLineSpacing = 0;
    layoutCollection.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.photosCollection = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layoutCollection];
    self.photosCollection.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    [self.photosCollection registerClass:[PhotoPlayerCell class] forCellWithReuseIdentifier:PHOTO_IDENTIFIER];
    self.photosCollection.backgroundColor = [UIColor clearColor];
    self.photosCollection.delegate = self;
    self.photosCollection.dataSource = self;
    self.photosCollection.showsHorizontalScrollIndicator = NO;
    self.photosCollection.pagingEnabled = YES;
    [self addSubview:self.photosCollection];
}
#pragma MARK - CollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPlayerCell *cell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:PHOTO_IDENTIFIER
                                       forIndexPath:indexPath];
    cell.photo.image = [self.photos objectAtIndex:indexPath.row];
    return (cell);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [UIApplication sharedApplication].keyWindow.bounds.size;
    if(_BGScrollView == nil){
        _BGScrollView = [[UIScrollView alloc]init];
        _BGScrollView.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _BGScrollView.contentSize = CGSizeMake(_BGScrollView.bounds.size.width * _photos.count, _BGScrollView.bounds.size.height);
        _BGScrollView.showsHorizontalScrollIndicator = NO;
        _BGScrollView.backgroundColor = [UIColor clearColor];
        _BGScrollView.pagingEnabled = YES;
        [self.superview addSubview:_BGScrollView];
        
    }
    NSInteger row = indexPath.row;
    for (NSInteger idx = 0;idx<_photos.count;idx++) {
        UIImage *image = [_photos objectAtIndex:idx];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = CGRectMake(idx*size.width, 0, size.width, size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        imageView.tag = idx + 1;
        UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureRecongnized:)];
        [imageView addGestureRecognizer:tapgesture];
        if(idx == row){
            imageView.frame = [collectionView cellForItemAtIndexPath:indexPath].bounds;
            imageView.center = CGPointMake(idx*size.width + _BGScrollView.bounds.size.width/2.0, _BGScrollView.bounds.size.height/2.0);
        }
        [_BGScrollView addSubview:imageView];
    }
    [_BGScrollView scrollRectToVisible:CGRectMake(row*size.width, 0, size.width, size.height) animated:NO];
    UIImageView *imageView = (UIImageView *)[_BGScrollView viewWithTag:row + 1];
    [UIView animateWithDuration:0.2 animations:^{
        imageView.frame = CGRectMake(row*size.width,0, size.width, size.height);
        _BGScrollView.backgroundColor = [UIColor blackColor];
    }];
}

-(void)tapGestureRecongnized:(UITapGestureRecognizer *)sender
{
    NSInteger row = sender.view.tag - 1;
    __block UIImageView *imageView;
    [UIView animateWithDuration:0.05 animations:^{
        [self.photosCollection scrollRectToVisible:CGRectMake(row*self.photosCollection.bounds.size.width, self.photosCollection.frame.origin.y, self.photosCollection.bounds.size.width, self.photosCollection.bounds.size.height) animated:NO];
        imageView =(UIImageView *)sender.view;

    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            _BGScrollView.backgroundColor = [UIColor clearColor];
            imageView.frame = [self.photosCollection cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]].bounds;
            imageView.center = CGPointMake(row*_BGScrollView.bounds.size.width + _BGScrollView.bounds.size.width/2.0, _BGScrollView.bounds.size.height/2.0);
        } completion:^(BOOL finished) {
            [_BGScrollView removeFromSuperview];
            _BGScrollView = nil;
        }];

    }];
}

-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.photosCollection removeFromSuperview];
    self.photosCollection = nil;
    [self.photos removeAllObjects];
    self.photos = nil;
}
@end

@implementation PhotoPlayerCell

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    self.photo = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    self.photo.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.photo];
    self.photo.backgroundColor = [UIColor blackColor];
    self.photo.center = self.contentView.center;
    return (self);
}
-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.photo removeFromSuperview];
    self.photo.image = nil;
    self.photo = nil;
}

@end
