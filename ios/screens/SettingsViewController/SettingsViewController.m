//
//  SettingsViewController.m
//  greenTravel
//
//  Created by Alex K on 25.12.22.
//

#import "SettingsViewController.h"
#import "SettingsModel.h"
#import "SettingsController.h"
#import "SettingsScreen.h"
#import "SettingsGroup.h"
#import "SettingsEntry.h"
#import "SettingsEntryToggle.h"
#import "SettingsEntrySelect.h"
#import "SettingsEntryAction.h"
#import "SettingsEntryInfo.h"
#import "SettingsEntryNavigate.h"
#import "SettingsEntryAuthLoggedOut.h"
#import "SettingsEntryAuthLoggedIn.h"
#import "SettingsActionTableViewCell.h"
#import "SettingsNavigateTableViewCell.h"
#import "SettingsSelectTableViewCell.h"
#import "SettingsToggleTableViewCell.h"
#import "SettingsBaseTableViewCell.h"
#import "SettingsAuthTableViewCell.h"
#import "AuthLoggedInTableViewCell.h"
#import "AuthLoggedOutTableViewCell.h"
#import "SettingsBaseTableViewCellConfig.h"
#import "Colors.h"
#import "StyleUtils.h"
#import "SettingsUtils.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SettingsModel *settingsModel;
@property (strong, nonatomic) SettingsController *settingsController;
@property (strong, nonatomic) SettingsScreen *root;

@end

static const CGFloat kSettingsRowHeight = 44.0;
static const CGFloat kAuthRowHeight = 96.0;
static NSString * const kActionCellId = @"actionCellId";
static NSString * const kToggleCellId = @"toggleCellId";
static NSString * const kSelectCellId = @"selectCellId";
static NSString * const kNavigateCellId = @"navigateCellId";
static NSString * const kBaseCellId = @"baseCellId";
static NSString * const kAuthCellId = @"authCellId";

@implementation SettingsViewController

- (instancetype)initWithSettingsController:(SettingsController *)settingsController
                             settingsModel:(SettingsModel *)settingsModel
                         settingsScreen:(SettingsScreen *)settingsScreen {
  if (self = [super init]) {
    _settingsModel = settingsModel;
    _settingsController = settingsController;
    _root = settingsScreen;
  }
  return self;
}

- (instancetype)initWithSettingsController:(SettingsController *)settingsController
                             settingsModel:(SettingsModel *)settingsModel{
  if (self = [super init]) {
    _settingsModel = settingsModel;
    _settingsController = settingsController;
    _root = settingsModel.tree;
  }
  return self;
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  configureNavigationBar(self.navigationController.navigationBar);
  self.view.backgroundColor = [Colors get].backgroundProfileScreen;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.settingsModel addSettingsModelObserver:self];
  if (@available(iOS 13.0, *)) {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
  } else {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
  }
  [self.view addSubview:self.tableView];
  self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
  ]];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView registerClass:SettingsActionTableViewCell.self forCellReuseIdentifier:kActionCellId];
  [self.tableView registerClass:SettingsToggleTableViewCell.self forCellReuseIdentifier:kToggleCellId];
  [self.tableView registerClass:SettingsSelectTableViewCell.self forCellReuseIdentifier:kSelectCellId];
  [self.tableView registerClass:SettingsNavigateTableViewCell.self forCellReuseIdentifier:kNavigateCellId];
  [self.tableView registerClass:SettingsBaseTableViewCell.self forCellReuseIdentifier:kBaseCellId];
  [self.tableView registerClass:SettingsAuthTableViewCell.self forCellReuseIdentifier:kAuthCellId];
  [self onSettingsModelScreenChange:self.settingsModel.tree];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSUInteger count = [self.root.groups[section].entries count];
  return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.root.groups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SettingsEntry *entry = self.root.groups[indexPath.section].entries[indexPath.row];

  if ([entry isKindOfClass:[SettingsEntryToggle class]]) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToggleCellId forIndexPath:indexPath];
    SettingsToggleTableViewCell *cellToggle = (SettingsToggleTableViewCell *) cell;
    SettingsEntryToggle *entryToggle = (SettingsEntryToggle *) entry;
    __weak typeof(self) weakSelf = self;
    [cellToggle update:entry.name enabled:entryToggle.enabled onToggle:^(BOOL enabled) {
      [weakSelf.settingsController interactWithSetting:entry onViewController:weakSelf];
    }];
    return cellToggle;
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedOut class]]) {
    SettingsEntryAuthLoggedOut *entryAuth = (SettingsEntryAuthLoggedOut *)entry;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAuthCellId forIndexPath:indexPath];
    SettingsAuthTableViewCell *cellAuth = (SettingsAuthTableViewCell *)cell;
    [cellAuth updateWithSubTitle:@"" fetchingInProgress:entryAuth.inProgress
                        signedIn:NO];
    return cell;
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedIn class]]) {
    SettingsEntryAuthLoggedIn *entryAuth = (SettingsEntryAuthLoggedIn *)entry;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAuthCellId forIndexPath:indexPath];
    SettingsAuthTableViewCell *cellAuth = (SettingsAuthTableViewCell *)cell;
    [cellAuth updateWithSubTitle:self.settingsModel.userEmail
              fetchingInProgress:entryAuth.inProgress signedIn:YES];
    return cell;
  }
  if ([entry isKindOfClass:[SettingsEntryNavigate class]]) {
    SettingsBaseTableViewCell *baseCell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId forIndexPath:indexPath];
    SettingsBaseTableViewCellConfig *config = [[SettingsBaseTableViewCellConfig alloc] initWithTitle:entry.name
                                                                                    subTitle:entry.value
                                                                                    iconName:entry.iconName
                                                                                    chevron:YES];
    [baseCell update:config];
    return baseCell;
  }
  if ([entry isKindOfClass:[SettingsEntryAction class]]) {
    SettingsEntryAction *entryAction = (SettingsEntryAction *)entry;
    SettingsBaseTableViewCell *baseCell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId forIndexPath:indexPath];
    SettingsBaseTableViewCellConfig *config = [[SettingsBaseTableViewCellConfig alloc] initWithTitle:entry.name
                                                                                    subTitle:entry.value
                                                                                    iconName:entry.iconName
                                                                                    chevron:entry.chevron];
    config.danger = entryAction.dangerous;
    [baseCell update:config];
    return baseCell;
  }

  SettingsBaseTableViewCell *baseCell = [tableView dequeueReusableCellWithIdentifier:kBaseCellId forIndexPath:indexPath];
  SettingsBaseTableViewCellConfig *config = [[SettingsBaseTableViewCellConfig alloc] initWithTitle:entry.name
                                                                                  subTitle:entry.value
                                                                                  iconName:entry.iconName
                                                                                  chevron:entry.chevron];
  [baseCell update:config];
  return baseCell;
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
  SettingsEntry *entry = self.root.groups[indexPath.section].entries[indexPath.row];
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedOut class]]) {
    return kAuthRowHeight;
  }
  return kSettingsRowHeight;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  SettingsEntry *entry = self.root.groups[indexPath.section].entries[indexPath.row];
  if ([entry isKindOfClass:[SettingsEntryInfo class]]) {
    return NO;
  }
  if ([entry isKindOfClass:[SettingsEntryToggle class]]) {
    return NO;
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedOut class]]) {
    SettingsEntryAuthLoggedOut *entryAuth = (SettingsEntryAuthLoggedOut *)entry;
    if (entryAuth.inProgress) {
      return NO;
    }
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedIn class]]) {
    SettingsEntryAuthLoggedIn *entryAuth = (SettingsEntryAuthLoggedIn *)entry;
    if (entryAuth.inProgress) {
      return NO;
    }
  }
  return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  SettingsEntry *entry = self.root.groups[indexPath.section].entries[indexPath.row];
  if ([entry isKindOfClass:[SettingsEntryToggle class]]) {
    return;
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedOut class]]) {
    SettingsEntryAuthLoggedOut *entryAuth = (SettingsEntryAuthLoggedOut *)entry;
    if (entryAuth.inProgress) {
      return;
    }
  }
  if ([entry isKindOfClass:[SettingsEntryAuthLoggedIn class]]) {
    SettingsEntryAuthLoggedIn *entryAuth = (SettingsEntryAuthLoggedIn *)entry;
    if (entryAuth.inProgress) {
      return;
    }
  }
  [self.settingsController interactWithSetting:entry onViewController:self];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  SettingsGroup *group = self.root.groups[section];
  return group.name;
}

- (void)onSettingsModelEntryChange:(nonnull SettingsEntry *)entry {
  //TODO: For toggle and select entries - apply change to individual cell.
  if ([self.root isEqual:entry.parentGroup.parentScreen]) {
    [self.tableView reloadData];
  }
}

- (void)onSettingsModelGroupChange:(nonnull SettingsGroup *)group {
  if ([self.root isEqual:group.parentScreen]) {
    [self.tableView reloadData];
  }
}

- (void)onSettingsModelScreenChange:(nonnull SettingsScreen *)screen {
  if (!treeContainsScreen(self.settingsModel.tree, self.root)) {
    [self.navigationController popToRootViewControllerAnimated:YES];
    return;
  }
  [self.tableView reloadData];
}

- (void)onSettingsModelTreeChange:(nonnull NSMutableArray<SettingsGroup *> *)tree {
  
}

- (void)onUserModelStateTransitionFrom:(UserModelState)prevState
                        toCurrentState:(UserModelState)currentState {
  // Find 4th tab controller in application.
  UITabBarController *tabController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
  if (tabController.viewControllers.count < 4) {
    return;
  }
  SettingsViewController *settingsViewController = (SettingsViewController *)tabController.viewControllers[3];
  BOOL root = settingsViewController == self;
  
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      __weak typeof(self) strongSelf = weakSelf;
      if (prevState == UserModelStateSignedIn &&
          currentState == UserModelStateSignOutInProgress && !root) {
        [strongSelf.navigationController popToRootViewControllerAnimated:YES];
        return;
      }
    });
  });
}


@end
