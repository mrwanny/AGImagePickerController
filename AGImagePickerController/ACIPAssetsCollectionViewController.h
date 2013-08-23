//
//  ACIPAssetsCollectionViewController.h
//  AGImagePickerController Demo
//
//  Created by Wanny Morellato on 8/23/13.
//  Copyright (c) 2013 Artur Grigor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AGImagePickerController.h"


@interface ACIPAssetsCollectionViewController : UICollectionViewController

@property (strong,nonatomic) ALAssetsGroup *assetsGroup;
@property (ag_weak, readonly) NSArray *selectedAssets;
@property (strong) AGImagePickerController *imagePickerController;


@end
