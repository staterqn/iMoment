//
//  PhotoThumbnailController.m
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/2.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import "PhotoThumbnailController.h"


# define CELL_PHOTO_IDENTIFIER  @"photoLibraryCell"

static const NSInteger maxNum = 10;

@interface PhotoThumbnailController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *photosCollection;
@property (nonatomic, strong) NSMutableArray *photosThumbnailLibrairy;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic,strong)  NSMutableDictionary *selectedDic;
@property (nonatomic,readwrite) NSInteger numberofPhotos;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,readwrite) NSString *contentTitle;
@end

@implementation PhotoThumbnailController


- (ALAssetsLibrary *) defaultAssetLibrairy {
    static ALAssetsLibrary *assetLibrairy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetLibrairy = [[ALAssetsLibrary alloc] init];
    });
    return (assetLibrairy);
}

-(instancetype)initWithDataSource:(NSMutableArray *)dataSource title:(NSString *)title
{
    if(self = [super init]){
        _dataSource = dataSource;
        _contentTitle = title;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.numberofPhotos = 0;
    [self addNavigationBar];
    [self addCollectionView];
}

-(void)addNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelPickPhoto:)];
    self.navigationItem.title = _contentTitle;

}
-(void)addCollectionView
{
    UICollectionViewFlowLayout *layoutCollection = [[UICollectionViewFlowLayout alloc] init];
    layoutCollection.itemSize = CGSizeMake(self.view.frame.size.width / 4 - 2, self.view.frame.size.width / 4 - 2);
    layoutCollection.minimumLineSpacing = 2;
    layoutCollection.minimumInteritemSpacing = 2;
    layoutCollection.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.photosCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layoutCollection];
    [self.photosCollection registerClass:[UICollectionViewCellPhoto class] forCellWithReuseIdentifier:CELL_PHOTO_IDENTIFIER];
    self.photosCollection.backgroundColor = [UIColor clearColor];
    self.photosCollection.delegate = self;
    self.photosCollection.dataSource = self;
    self.photosCollection.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.photosCollection];
}

-(void)loadPhotoFromLibrary
{
    self.photosThumbnailLibrairy = [[NSMutableArray alloc] init];
    self.selectedPhotos = [[NSMutableArray alloc]init];
    self.selectedDic = [NSMutableDictionary dictionary];
    ALAssetsLibrary *library = [self defaultAssetLibrairy];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil){
            NSLog(@"%ld",group.numberOfAssets);
        }
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsWithOptions:NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result){
                [self.photosThumbnailLibrairy addObject:result];
                [self.photosCollection reloadData];
            }
            if(*stop == YES){
                NSLog(@"sdsds");
            }
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"esdfsdsdsd");
    }];
}

#pragma MARK - CollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCellPhoto *cell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:CELL_PHOTO_IDENTIFIER
                                       forIndexPath:indexPath];
    
    ALAsset *asset = [self.dataSource objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
    cell.photo.image = image;
    BOOL selected = [self.selectedDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]] ? YES : NO;
    [cell updateSelectStatus:selected];
    return (cell);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCellPhoto *cell =(UICollectionViewCellPhoto *)[collectionView cellForItemAtIndexPath:indexPath];
//    NSNumber *num = [self.selectedDic objectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
//    if(num){
//        self.numberofPhotos--;
//       [self.selectedPhotos removeObject:[self.photosThumbnailLibrairy objectAtIndex:indexPath.row]];
//       [self.selectedDic removeObjectForKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
//       [cell updateSelectStatus:NO];
//    }else {
//        if(self.numberofPhotos>= maxNum){
//            [self showAlterView];
//            return;
//        }
//      self.numberofPhotos ++;
//      [self.selectedPhotos addObject:[self.photosThumbnailLibrairy objectAtIndex:indexPath.row]];
//      [self.selectedDic setObject:[NSNumber numberWithInteger:indexPath.row] forKey:[NSString stringWithFormat:@"%ld",indexPath.row]];
//      [cell updateSelectStatus:YES];
//    }
   
}
#pragma MARK- Click Event

-(IBAction)cancelPickPhoto:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self removeAllCaches];
    }];
}
-(IBAction)pickPhotoFinished:(id)sender
{
   [self dismissViewControllerAnimated:YES completion:^{
       if(self.delegate && [self.delegate respondsToSelector:@selector(photoPickerCompleted:)]){
           [self.delegate photoPickerCompleted:self.selectedPhotos];
       }
       [self removeAllCaches];
   }];
}

#pragma MARK Remove

-(void)removeAllCaches
{
    [self.photosCollection removeFromSuperview];
    self.photosCollection = nil;
    [self.photosThumbnailLibrairy removeAllObjects];
    self.photosThumbnailLibrairy = nil;
    [self.selectedDic removeAllObjects];
    self.selectedDic = nil;
}

-(void)showAlterView
{
    UIAlertView *alterView = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"不能选择大于%ld张",(long)maxNum] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alterView show];
}
@end

@implementation UICollectionViewCellPhoto

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.photo = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.photo];
    self.maskView = [[UIView alloc]initWithFrame:self.contentView.bounds];
    self.maskView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self.contentView addSubview:self.maskView];
    self.maskView.alpha = 0.0;
    return (self);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.photo.image = nil;
    self.photo.frame = self.contentView.bounds;
}

-(void)updateSelectStatus:(BOOL)selected
{
    if(selected){
       [UIView animateWithDuration:0.1 animations:^{
           self.maskView.alpha = 1.0;
       }];
    }else {
        [UIView animateWithDuration:0.1 animations:^{
            self.maskView.alpha = 0.0;
        }];
    }
}

-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.photo removeFromSuperview];
    self.photo = nil;
    [self.maskView removeFromSuperview];
    self.maskView = nil;
}

@end
