//
//  RootViewController.m
//  RsSchoolTask2.6
//
//  Created by Alex K on 6/20/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "RootViewController.h"
#import "MainViewController.h"
#import "Colors.h"
#import "TextUtils.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "RNBootSplash.h"

#ifdef FB_SONARKIT_ENABLED
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h> 
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>

static void InitializeFlipper(UIApplication *application) {
  FlipperClient *client = [FlipperClient sharedClient];
  SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
  [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
  [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
  [client addPlugin:[FlipperKitReactPlugin new]];
  [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
  [client start];
}
#endif


@interface RootViewController ()

@property (strong, nonatomic) UIViewController *current;
@property (weak, nonatomic) UIApplication *application;
@property (strong, nonatomic) NSDictionary *launchOptions;

@end

@implementation RootViewController

- (instancetype)initWithApplication:(UIApplication *)application
                      launchOptions:(NSDictionary *)launchOptions
{
    self = [super init];
    if (self) {
        _application = application;
        _launchOptions = launchOptions;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self showNativeViewController];
}

- (void)showRNViewController {
#ifdef FB_SONARKIT_ENABLED
  InitializeFlipper(self.application);
#endif
  UIViewController *rnViewController = [[UIViewController alloc] init];
    RCTBridge *bridge =
    [[RCTBridge alloc] initWithDelegate:self launchOptions:self.launchOptions]; 
    RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                     moduleName:@"greenTravel"
                                              initialProperties:nil];
    rootView.backgroundColor =
    [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    rnViewController.view = rootView;
    
    [self addChildViewController:rnViewController];
    rnViewController.view.frame = self.view.bounds;
    [self.view addSubview:rnViewController.view];
    [rnViewController didMoveToParentViewController:self];
    
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    
    self.current = rnViewController;
}

- (void)showNativeViewController {
    MainViewController *mainViewController = [[MainViewController alloc] init];
    
    [self addChildViewController:mainViewController];
    mainViewController.view.frame = self.view.bounds;
    [self.view addSubview:mainViewController.view];
    [mainViewController didMoveToParentViewController:self];
    
    [self.current willMoveToParentViewController:nil];
    [self.current.view removeFromSuperview];
    [self.current removeFromParentViewController];
    
    self.current = mainViewController;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end
