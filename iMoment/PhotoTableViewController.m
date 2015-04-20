//
//  PhotoTableViewController.m
//  iMoment
//
//  Created by chuanshuangzhang chuan shuang on 15/4/7.
//  Copyright (c) 2015年 chuanshaungzhang. All rights reserved.
//

#import "PhotoTableViewController.h"
#import "PhotoThumbnailController.h"

@interface PhotoTableViewController ()

@property (nonatomic,strong)  NSMutableArray *photos;
@property (nonatomic,strong)  NSMutableArray *photoTittles;
@end

@implementation PhotoTableViewController



- (ALAssetsLibrary *) defaultAssetLibrairy {
    static ALAssetsLibrary *assetLibrairy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetLibrairy = [[ALAssetsLibrary alloc] init];
    });
    return (assetLibrairy);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationBar];
    [self.tableView registerClass:[PhotTableCell class] forCellReuseIdentifier:@"PhotTableCell"];
    [self loadPhotoFromLibrary];
}
-(void)addNavigationBar
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelPickPhoto:)];
}

-(void)loadPhotoFromLibrary
{
    self.photos = [NSMutableArray array];
    self.photoTittles = [NSMutableArray array];
    __block NSMutableArray *titleArray = [NSMutableArray arrayWithObjects:@"其他",@"新增",@"资源库",@"相机交卷", nil];
    ALAssetsLibrary *library = [self defaultAssetLibrairy];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        NSMutableArray *array;
        if(group.numberOfAssets>0){
          array = [NSMutableArray array];
            [self.photos addObject:array];
            if(titleArray.count<=0){
                [titleArray addObject:@"其他"];
            }
            [self.photoTittles addObject:[titleArray objectAtIndex:0]];
            [titleArray removeObjectAtIndex:0];
        }
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result && array){
                [array addObject:result];
                [self.tableView reloadData];
            }
        }];
    } failureBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.photos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotTableCell *cell =  (PhotTableCell *)[tableView dequeueReusableCellWithIdentifier:@"PhotTableCell" forIndexPath:indexPath];
    NSMutableArray *array = [self.photos objectAtIndex:indexPath.row];
    ALAsset *asset = [array objectAtIndex:0];
    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
    cell.leftImageView.image = image;
    cell.textDescription.text = [NSString stringWithFormat:@"%@(%ld)",[self.photoTittles objectAtIndex:indexPath.row],array.count];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *array = [self.photos objectAtIndex:indexPath.row];
    PhotoThumbnailController *vc = [[PhotoThumbnailController alloc]initWithDataSource:array title:[self.photoTittles objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}
-(IBAction)cancelPickPhoto:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end

@implementation PhotTableCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
    
        self.leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,40,40)];
        self.leftImageView.center = CGPointMake(30, 25);
        self.rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,40,40)];
        self.rightImageView.center = CGPointMake(self.bounds.size.width-30, 25);
        self.textDescription = [[UILabel alloc]init];
        [self.textDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.contentView addSubview:self.textDescription];
        [self.contentView addSubview:self.leftImageView];
        [self.contentView addSubview:self.rightImageView];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textDescription attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.textDescription attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.leftImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:10]];
    }
    return (self);
}

@end
