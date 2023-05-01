//
//  RootViewController.h
//  RsSchoolTask2.6
//
//  Created by Alex K on 6/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootViewController : UIViewController

@property (strong, nonatomic) UIViewController *current;

- (instancetype)initWithApplication:(UIApplication *)application
                      launchOptions:(NSDictionary *)launchOptions;
- (void)showRNViewController;
- (void)showNativeViewController;
- (void)loadCategories;
- (void)initRNBootSplash;
- (bool)getIsNativeControllerShouldBeLaunched;

@end

NS_ASSUME_NONNULL_END
