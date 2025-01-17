//
//  SettingsBaseTableViewCell.m
//  greenTravel
//
//  Created by Alex K on 21.01.23.
//

#import "SettingsBaseTableViewCell.h"
#import "ColorsLegacy.h"
#import "Colors.h"
#import "TextUtils.h"
#import "SettingsBaseTableViewCellConfig.h"
#import "Typography.h"

@interface SettingsBaseTableViewCell ()

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *subTitle;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UIView *separatorView;
@property (strong, nonatomic) UIStackView *labelStack;
@property (strong, nonatomic) SettingsBaseTableViewCellConfig *config;
@property (strong, nonatomic) NSLayoutConstraint *titleLeading;
@property (strong, nonatomic) NSLayoutConstraint *titleTrailing;
@property (strong, nonatomic) NSLayoutConstraint *subTitleTrailing;

@end

static const CGFloat kIconSize = 30.0;
static const CGFloat kSpacing = 16.0;

@implementation SettingsBaseTableViewCell

- (void)layoutSubviews {
  [super layoutSubviews];
  if (self.config.danger) {
    [self.title setAttributedText:[[Typography get] settingsCellTitleDanger:self.config.title]];
  } else {
    [self.title setAttributedText:[[Typography get] settingsCellTitle:self.config.title]];
  }
  if (self.config.subTitle != nil) {
    [self.subTitle setAttributedText:[[Typography get] settingsCellSubTitle:self.config.subTitle]];
  }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
#pragma mark - Icon
  UIImage *image = nil;
  if (self.config.iconName) {
    image = [UIImage imageNamed:self.config.iconName];
  }
  self.iconView = [[UIImageView alloc] initWithImage:image];
  self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:self.iconView];
  
  [NSLayoutConstraint activateConstraints:@[
    [self.iconView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:kSpacing],
    [self.iconView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
    [self.iconView.widthAnchor constraintEqualToConstant:kIconSize],
    [self.iconView.heightAnchor constraintEqualToConstant:kIconSize],
  ]];
#pragma mark - Sub title
  self.subTitle = [[UILabel alloc] init];
  [self.contentView addSubview:self.subTitle];
  self.subTitle.numberOfLines = 1;
  self.subTitle.adjustsFontSizeToFitWidth = NO;
  [self.subTitle setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
  self.subTitle.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [self.subTitle.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
    self.subTitleTrailing = [self.subTitle.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-kSpacing]
  ]];
#pragma mark - Title
  self.title = [[UILabel alloc] init];
  [self.contentView addSubview:self.title];
  self.title.numberOfLines = 1;
  self.title.adjustsFontSizeToFitWidth = NO;
  [self.title setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
  [self.title setLineBreakMode:NSLineBreakByTruncatingTail];
  self.title.translatesAutoresizingMaskIntoConstraints = NO;
  
  [NSLayoutConstraint activateConstraints:@[
    [self.title.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
    self.titleLeading = [self.title.leadingAnchor constraintEqualToAnchor:self.iconView.trailingAnchor constant:kSpacing],
    self.titleTrailing = [self.title.trailingAnchor
                             constraintLessThanOrEqualToAnchor:self.subTitle.leadingAnchor constant:-kSpacing],
  ]];
#pragma mark - Accessory view
  self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)update:(SettingsBaseTableViewCellConfig *)entry {
  self.config = entry;
  
#pragma mark - Icon
  BOOL iconIsPresent = self.config.iconName != nil && ![self.config.iconName isEqualToString:@""];
  if (iconIsPresent) {
    [self.iconView setImage:[UIImage imageNamed:self.config.iconName]];
    [self.iconView setHidden:NO];
  } else {
    [self.iconView setHidden:YES];
  }
#pragma mark - Sub title
  BOOL subTitleIsPresent = self.config.subTitle != nil;
  if (subTitleIsPresent) {
    [self.subTitle setAttributedText:[[Typography get] settingsCellSubTitle:self.config.subTitle]];
    [self.subTitle setHidden:NO];
  } else {
    [self.subTitle setAttributedText:[[Typography get] settingsCellSubTitle:@""]];
    [self.subTitle setHidden:YES];
  }
#pragma mark - Title
  if (entry.danger) {
    [self.title setAttributedText:[[Typography get] settingsCellTitleDanger:self.config.title]];
  } else {
    [self.title setAttributedText:[[Typography get] settingsCellTitle:self.config.title]];
  }
  if (iconIsPresent) {
    self.titleLeading.constant = kSpacing;
  } else {
    self.titleLeading.constant = -2 * kSpacing;
  }
  if (subTitleIsPresent) {
    self.titleTrailing.constant = -kSpacing;
  } else {
    self.titleTrailing.constant = kSpacing;
  }
#pragma mark - Accessory view
  if (self.config.chevron) {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    self.accessoryType = UITableViewCellAccessoryNone;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [self.iconView setHidden:YES];
  self.accessoryType = UITableViewCellAccessoryNone;
  [self.subTitle setHidden:YES];
  [self.title setAttributedText:[[Typography get] settingsCellTitle:@""]];
  [self.subTitle setAttributedText:[[Typography get] settingsCellTitle:@""]];
}

@end
