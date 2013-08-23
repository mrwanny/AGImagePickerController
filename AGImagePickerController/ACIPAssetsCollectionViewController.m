//
//  ACIPAssetsCollectionViewController.m
//  AGImagePickerController Demo
//
//  Created by Wanny Morellato on 8/23/13.
//  Copyright (c) 2013 Artur Grigor. All rights reserved.
//

#import "ACIPAssetsCollectionViewController.h"

@interface ACIPAssetsCollectionViewController ()

@property (strong,nonatomic) NSMutableArray *assets;

@end

@implementation ACIPAssetsCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Fullscreen
    if (self.imagePickerController.shouldChangeStatusBarStyle) {
        self.wantsFullScreenLayout = YES;
    }
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"BasicCell"];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    // Setup Notifications
    [self registerForNotifications];
    
    if (self.imagePickerController.maximumNumberOfPhotosToBeSelected == 1) {
        // we do not need to show the done button
    } else {
        // Navigation Bar Items
        UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
        doneButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem = doneButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAssetsGroup:(ALAssetsGroup *)theAssetsGroup
{
    @synchronized (self)
    {
        if (_assetsGroup != theAssetsGroup)
        {
            _assetsGroup = theAssetsGroup;
            [_assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            [self loadAssets];
        }
    }
}

- (void)loadAssets
{
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithCapacity:1];
    }
    [self.assets removeAllObjects];
    
    __ag_weak ACIPAssetsCollectionViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        __strong ACIPAssetsCollectionViewController *strongSelf = weakSelf;
        
        @autoreleasepool {
            [strongSelf.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result == nil)
                {
                    return;
                }
                [strongSelf.assets addObject:result];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [strongSelf reloadData];
            NSLog(@"reload data");
            
        });
        
    });
}


- (void)reloadData
{
    // Don't display the select button until all the assets are loaded.
//    [self.navigationController setToolbarHidden:[self toolbarHidden] animated:YES];
    
    [self.collectionView reloadData];
    [self setTitle:[self.assetsGroup valueForProperty:ALAssetsGroupPropertyName]];
//    [self changeSelectionInformation];
    
    NSInteger totalRows = [self.collectionView numberOfItemsInSection:0];
    
    //Prevents crash if totalRows = 0 (when the album is empty).
    if (totalRows > 0) {
        
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:totalRows-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom  animated:NO];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.assets count];
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderCell" forIndexPath:indexPath];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"BasicCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIImageView *thumb = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:[self.assets[indexPath.item] thumbnail]]];
    [cell.contentView addSubview:thumb];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75 , 75);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.imagePickerController.maximumNumberOfPhotosToBeSelected == 1) {
        [self.imagePickerController performSelector:@selector(didFinishPickingAssets:) withObject:@[self.assets[indexPath.item]]];
        return;
    }else {
        NSLog(@"********* multiple selection not supported yet");
    }
}


#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeLibrary:)
                                                 name:ALAssetsLibraryChangedNotification
                                               object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)unregisterFromNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ALAssetsLibraryChangedNotification
                                                  object:[AGImagePickerController defaultAssetsLibrary]];
}

- (void)didChangeLibrary:(NSNotification *)notification
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didChangeToolbarItemsForManagingTheSelection:(NSNotification *)notification
{
    NSLog(@"here.");
}

@end
