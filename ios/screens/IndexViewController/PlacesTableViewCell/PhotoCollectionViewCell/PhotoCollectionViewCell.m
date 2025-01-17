//
//  PhotoCollectionViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlaceItem.h"
#import "PlaceCategory.h"
#import "PhotoCollectionViewCell.h"
#import "StyleUtils.h"
#import "GradientOverlayView.h"
#import "ColorsLegacy.h"
#import "Colors.h"
#import "TextUtils.h"
#import "ImageUtils.h"
#import "TypographyLegacy.h"
#import "BookmarkButton.h"
#import "UIImage+extensions.h"

@interface PhotoCollectionViewCell ()

@property (strong, nonatomic) PlaceCategory *category;
@property (strong, nonatomic) PlaceItem *item;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *favoritesButton;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIImageView *placeholder;
@property (strong, nonatomic) SDWebImageCombinedOperation *loadImageOperation;

@end

static const CGFloat kHeaderLabelTop = 16.0;
static const CGFloat kGradientOffset = 50.0;
static NSCache *imageCache = nil;

@implementation PhotoCollectionViewCell

+ (UIImage *)imageForType:(PhotoCollectionViewCellImageType)imageType
                baseImage:(nonnull UIImage *)baseImage {
  if (imageCache == nil) {
    imageCache = [NSCache new];
  }
  if ([imageCache objectForKey:@(imageType)] == nil) {
    UIColor *color = (imageType == PhotoCollectionViewCellImageTypeLight ||
                      imageType == PhotoCollectionViewCellImageTypeLightSelected) ?
    [Colors get].bookmarkTintFullCell :
    [Colors get].bookmarkTintEmptyCell;

    UIImage *image = [baseImage tintedImage:color];
    [imageCache setObject:image forKey:@(imageType)];
  }
  return [imageCache objectForKey:@(imageType)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews {
  self.placeholder.backgroundColor = [Colors get].cardPlaceholder;
  [super layoutSubviews];
  [self updateOverlayAndShadow];
  self.layer.borderColor = [[Colors get].photoCollectionViewCellBorder CGColor];
  BOOL bookmarkSelected = self.favoritesButton.selected;
  if (self.item != nil && ![self coverIsPresent]) {
    PhotoCollectionViewCellImageType imageType = bookmarkSelected ?
    PhotoCollectionViewCellImageTypeDarkSelected : PhotoCollectionViewCellImageTypeDark;
    self.favoritesButton.imageView.image =
    [PhotoCollectionViewCell imageForType:imageType
                                baseImage:self.favoritesButton.imageView.image];
    self.headerLabel.attributedText = [[TypographyLegacy get] makeTitle2:self.item.title
                                                                   color:[Colors get].cardPlaceholderText];
    return;
  }
  
  PhotoCollectionViewCellImageType imageType = bookmarkSelected ?
  PhotoCollectionViewCellImageTypeLightSelected : PhotoCollectionViewCellImageTypeLight;
  self.favoritesButton.imageView.image =
  [PhotoCollectionViewCell imageForType:imageType
                              baseImage:self.favoritesButton.imageView.image];
}

- (void)setUp {
#pragma mark - Image
    self.placeholder = [[UIImageView alloc] init];
    self.overlayView = [[GradientOverlayView alloc] initWithFrame:CGRectZero];

    [self addSubview:self.placeholder];

    self.placeholder.contentMode = UIViewContentModeScaleAspectFill;
    self.placeholder.translatesAutoresizingMaskIntoConstraints = NO;

    self.placeholder.layer.cornerRadius = 4.0;
    self.placeholder.layer.masksToBounds = YES;

    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;

    [NSLayoutConstraint activateConstraints:@[
        [self.placeholder.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.placeholder.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.placeholder.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.placeholder.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];


#pragma mark - Header label
    self.headerLabel = [[UILabel alloc] init];
    [self addSubview:self.headerLabel];

    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserrat-Bold" size:15.0]];
     [self.headerLabel setNumberOfLines:0];

    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:kHeaderLabelTop],
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
    ]];

  [self.placeholder addSubview:self.overlayView];
  self.overlayView.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
      [self.overlayView.topAnchor constraintEqualToAnchor:self.placeholder.topAnchor],
      [self.overlayView.leadingAnchor constraintEqualToAnchor:self.placeholder.leadingAnchor],
      [self.overlayView.trailingAnchor constraintEqualToAnchor:self.placeholder.trailingAnchor],
      [self.overlayView.heightAnchor constraintEqualToAnchor:self.headerLabel.heightAnchor constant:kHeaderLabelTop + kGradientOffset]
  ]];
#pragma mark - Favorites button
    __weak typeof(self) weakSelf = self;
    self.favoritesButton = [[BookmarkButton alloc] initWithFlavor:BookmarkButtonFlavorIndex
                                                  onBookmarkPress:^(BOOL selected) {
      weakSelf.item.onFavoriteButtonPress();
    }];
    self.favoritesButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.favoritesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    [self addSubview:self.favoritesButton];

    self.favoritesButton.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [self.favoritesButton.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.favoritesButton.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.headerLabel.trailingAnchor constant:16.0],
        [self.favoritesButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.favoritesButton.widthAnchor constraintEqualToConstant:44.0],
        [self.favoritesButton.heightAnchor constraintEqualToConstant:44.0],
    ]];

    UIImageView *favoritesButtonImageView = self.favoritesButton.imageView;
    favoritesButtonImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [favoritesButtonImageView.topAnchor constraintEqualToAnchor:self.headerLabel.topAnchor],
    ]];

    [self.overlayView setHidden:YES];
}

- (void)onFavoritePress:(id)sender {
    self.item.onFavoriteButtonPress();
}

- (void)onPlaceButtonPress:(id)sender {

}

- (BOOL)coverIsPresent {
  return self.item != nil && self.item.cover != nil &&
      self.item.cover != [NSNull null] && [self.item.cover length] > 0 && self.placeholder.image != nil;
}

- (void)updateItem:(PlaceItem *)item {
    self.item = item;
    self.headerLabel.attributedText = [[TypographyLegacy get] makeTitle2:item.title
                                                             color:[Colors get].cardPlaceholderText];
    [self.favoritesButton setHidden:NO];
    [self.favoritesButton setSelected:item.bookmarked];
    if (item.cover != nil && item.cover != [NSNull null] &&
        [item.cover length] > 0) {
        __weak typeof (self) weakSelf = self;
        self.loadImageOperation = loadImage(item.cover, ^(UIImage *image, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateSubviews:item.title image:image];
            });
        });
    } else {
        [self.placeholder setImage:nil];
    }

    [self updateOverlayAndShadow];
}

- (void)updateSubviews:(NSString *)title image:(UIImage *)image {
  if (image == nil) {
    return;
  }
  self.headerLabel.attributedText = [[TypographyLegacy get] makeTitle2:title
                                                           color:[ColorsLegacy get].white];
  [self.favoritesButton setTintColor:[Colors get].bookmarkTintEmptyCell];
  [self.placeholder setImage:image];
  [self.overlayView setHidden:NO];
}

- (void)updateBookmark:(BOOL)bookmark {
    NSLog(@"updateBookmark");
    [self.favoritesButton setSelected:bookmark];
}

- (void)updateCategory:(PlaceCategory *)category {
     self.headerLabel.attributedText = [[TypographyLegacy get] makeTitle2:category.title
                                                              color:[Colors get].cardPlaceholderText];
    [self.favoritesButton setHidden:YES];
    if (category.cover != nil && category.cover != [NSNull null] &&
        [category.cover length] > 0) {
        __weak typeof (self) weakSelf = self;
        self.loadImageOperation = loadImage(category.cover, ^(UIImage *image, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateSubviews:category.title image:image];
            });
        });
    } else {
        [self.placeholder setImage:nil];
    }
    [self updateOverlayAndShadow];
}

- (void)updateOverlayAndShadow {
    drawShadow(self);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.loadImageOperation cancel];
    [self.favoritesButton setTintColor:[Colors get].bookmarkTintEmptyCell];
    [self.placeholder setImage:nil];
    [self.overlayView setHidden:YES];
    self.headerLabel.text = @"";
    self.layer.shadowPath = nil;
}

@end
