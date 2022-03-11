//
//  PlacesTableViewCell.m
//  GreenTravel
//
//  Created by Alex K on 8/16/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

#import "PlacesTableViewCell.h"
#import "PhotoCollectionViewCell.h"
#import "ColorsLegacy.h"
#import "Colors.h"
#import "TextUtils.h"
#import "PlaceCategory.h"
#import "PlaceItem.h"
#import "SizeUtils.h"
#import "TypographyLegacy.h"
#import "IndexViewControllerConstants.h"
#import "CategoryUtils.h"
#import "NumberUtils.h"

static NSString * const kPhotoCellId = @"photoCellId";
static NSUInteger kMaximalNumberOfItemsInCell = 10;
static CGFloat kSwipeThresholdVelocity = 0.5;
static CGFloat kDraggedDistanceToWidthRatioThreshold = 0.2;
static CGFloat kDurationMax = 0.4;
static CGFloat kDurationMin = 0.1;

@interface PlacesTableViewCell ()

@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *allButton;
@property (strong, nonatomic) NSArray<PlaceItem *> *dataSourceItems;
@property (strong, nonatomic) NSArray<PlaceCategory *> *dataSourceCategories;
@property (strong, nonatomic) PlaceCategory *item;
@property (assign, nonatomic) CGSize cellSize;
@property (assign, nonatomic) NSInteger indexOfMostExposedCellBeforeDragging;
@property (assign, nonatomic) CGRect lastFrame;
@property (assign, nonatomic) CGFloat initialContentOffsetX;
@property (assign, nonatomic) CGFloat maxDragDistanceFromRight;
@property (assign, nonatomic) CGFloat maxDragDistanceFromLeft;

@end

@implementation PlacesTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.collectionView.backgroundColor = [Colors get].background;
  self.backgroundColor = [Colors get].background;
  
  [self.allButton setAttributedTitle:[[TypographyLegacy get]
                                      makeSubtitle1Semibold:NSLocalizedString(@"IndexAll", @"")
                                      color:[Colors get].buttonAll]
                            forState:UIControlStateNormal];
  self.headerLabel.attributedText = [[TypographyLegacy get] makeSubtitle1Semibold:[self.item.title uppercaseString]
                                     color:[Colors get].categoryTitleText];
  if (!CGRectEqualToRect(self.frame, self.lastFrame)) {
    self.lastFrame = self.frame;
    NSUInteger safeIndex = [self indexOfMostExposedCell];
    [self scrollToIndex:safeIndex animated:NO];
  }
}

- (void)setUp {
    self.lastFrame = CGRectZero;
    self.headerLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.headerLabel];
    [self.headerLabel setFont:[UIFont fontWithName:@"Montserrat-SemiBold" size:14.0]];
    
    self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.headerLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:16.0],
        [self.headerLabel.topAnchor constraintEqualToAnchor:self.topAnchor constant:24.0]
    ]];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:PhotoCollectionViewCell.class forCellWithReuseIdentifier:kPhotoCellId];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    [self.contentView addSubview:self.collectionView];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0.0],
        [self.collectionView.topAnchor constraintEqualToAnchor:self.headerLabel.bottomAnchor constant:0.0],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0.0],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0.0],
    ]];
    
    self.allButton = [[UIButton alloc] init];
    [self.contentView addSubview:self.allButton];
    [self.allButton.titleLabel setFont:[UIFont fontWithName:@"Montserrat-SemiBold" size:14.0]];
    
    [self.allButton addTarget:self action:@selector(onAllButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.allButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.allButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-16.0],
        [self.allButton.centerYAnchor constraintEqualToAnchor:self.headerLabel.centerYAnchor],
        [self.allButton.widthAnchor constraintEqualToConstant:44.0],
        [self.allButton.heightAnchor constraintEqualToConstant:44.0],
    ]];
    
#pragma mark - Subscribe to orientation change
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - Orientation change
- (void)onDeviceOrientationChange:(id)sender {
}

- (void)update:(PlaceCategory *)item {
    self.headerLabel.attributedText = [[TypographyLegacy get] makeSubtitle1Semibold:[item.title uppercaseString]];
    if ([item.categories count] > 0) {
        self.dataSourceCategories = [item.categories subarrayWithRange:NSMakeRange(0, MIN([item.categories count], kMaximalNumberOfItemsInCell))];
    } else {
        self.dataSourceItems = [item.items subarrayWithRange:NSMakeRange(0, MIN([item.items count], kMaximalNumberOfItemsInCell))];
    }
    [self.allButton setHidden:([self.dataSourceItems count] + [self.dataSourceCategories count] <= 1)];
    self.item = item;
    [self.collectionView reloadData];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger howManyCategories = [self.dataSourceCategories count];
    if (howManyCategories > 0) {
        return howManyCategories;
    }
    return [self.dataSourceItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForItemAtIndexPath method, index path: %@", indexPath);
    
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellId forIndexPath:indexPath];
    if ([self.dataSourceCategories count] > 0) {
        [cell updateCategory:self.dataSourceCategories[indexPath.row]];
        return cell;
    }
    [cell updateItem:self.dataSourceItems[indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGSize screenSize = [UIScreen mainScreen].bounds.size;
  CGSize adaptedSize = CGSizeMake(screenSize.width - 50, screenSize.height);
  self.cellSize = getCoverSize(adaptedSize);
  return self.cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Did select item at index path: %@", indexPath);
    if ([self.dataSourceCategories count] > 0) {
        PlaceCategory *category = self.dataSourceCategories[indexPath.row];
        category.onPlaceCellPress();
        return;
    }
    
    PlaceItem *item = self.dataSourceItems[indexPath.row];
    item.onPlaceCellPress();
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  __weak PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  [UIView animateWithDuration:0.3 animations:^{
    cell.alpha = 0.8;
  }];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  __weak PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  [UIView animateWithDuration:0.3 animations:^{
    cell.alpha = 1;
  }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.dataSourceCategories = @[];
    self.dataSourceItems = @[];
}

- (void)onAllButtonPress:(id)sender {
    self.item.onAllButtonPress();
}

#pragma mark - <UICollectionViewDelegate>
static const CGFloat kSpacing = 16.0;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return kSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(IndexViewControllerCoverInset,
                            IndexViewControllerCoverInset,
                            IndexViewControllerCoverInset,
                            IndexViewControllerCoverInset);
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
  NSUInteger safeIndex = [self indexOfMostExposedCell];
  NSUInteger dataSourceCount = self.dataSourceCategories.count > 0 ?
  self.dataSourceCategories.count : self.dataSourceItems.count;
  NSLog(@"End velocity: %f", velocity.x);
  NSLog(@"self.indexOfMostExposedCellBeforeDragging: %ld", (long) self.indexOfMostExposedCellBeforeDragging);
  NSLog(@"safeIndex: %ld", safeIndex);
  //Dragging to the left or edge.
  if ((velocity.x > 0 && (self.indexOfMostExposedCellBeforeDragging + 1) == dataSourceCount) ||
      (velocity.x < 0 && (self.indexOfMostExposedCellBeforeDragging - 1) < 0)) {
    return;
  }
  if (self.indexOfMostExposedCellBeforeDragging == safeIndex) {
    CGFloat ratioDraggedToWidth = self.maxDragDistanceFromLeft / self.cellSize.width;
    NSLog(@"ratioDraggedToWidth leading: %f", ratioDraggedToWidth);
    if (velocity.x > kSwipeThresholdVelocity && ratioDraggedToWidth < -kDraggedDistanceToWidthRatioThreshold &&
        self.indexOfMostExposedCellBeforeDragging == 0) {
      [self scrollToIndex:0
                 velocity:velocity targetContentOffset:targetContentOffset];
      return;
    }
    ratioDraggedToWidth = self.maxDragDistanceFromRight / self.cellSize.width;
    NSLog(@"ratioDraggedToWidth trailing: %f", ratioDraggedToWidth);
    if (velocity.x < -kSwipeThresholdVelocity && ratioDraggedToWidth > kDraggedDistanceToWidthRatioThreshold &&
        self.indexOfMostExposedCellBeforeDragging == dataSourceCount - 1) {
      [self scrollToIndex:dataSourceCount - 1
                 velocity:velocity targetContentOffset:targetContentOffset];
      return;
    }
    if (velocity.x > kSwipeThresholdVelocity && (self.indexOfMostExposedCellBeforeDragging + 1) < dataSourceCount) {
      [self scrollToIndex:self.indexOfMostExposedCellBeforeDragging + 1
                 velocity:velocity targetContentOffset:targetContentOffset];
      return;
    }
    if (velocity.x < -kSwipeThresholdVelocity && (self.indexOfMostExposedCellBeforeDragging - 1) >= 0) {
      [self scrollToIndex:self.indexOfMostExposedCellBeforeDragging - 1
                 velocity:velocity targetContentOffset:targetContentOffset];
      return;
    }
  }
  if (velocity.x > kSwipeThresholdVelocity && self.indexOfMostExposedCellBeforeDragging - 1 == safeIndex) {
    [self scrollToIndex:self.indexOfMostExposedCellBeforeDragging
               velocity:velocity targetContentOffset:targetContentOffset];
    return;
  }
  if (velocity.x < -kSwipeThresholdVelocity && self.indexOfMostExposedCellBeforeDragging + 1 == safeIndex) {
    [self scrollToIndex:self.indexOfMostExposedCellBeforeDragging
               velocity:velocity targetContentOffset:targetContentOffset];
    return;
  }
  [self stopDeceleration:targetContentOffset];
  if (fabs(velocity.x) > 0) {
    CGFloat predictedOffset = [self offsetByIndex:safeIndex];
    CGFloat duration = fabs(self.collectionView.contentOffset.x - predictedOffset) / (fabs(velocity.x) * 1000.0);
    duration = fclamp(duration, kDurationMin, kDurationMax);
    NSLog(@"Duration: %f", duration);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:safeIndex inSection:0];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
      [weakSelf.collectionView scrollToItemAtIndexPath:indexPath
                                  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                          animated:NO];
    } completion:nil];
    return;
  }
  [self scrollToIndex:safeIndex animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  self.maxDragDistanceFromLeft = fmin(self.collectionView.contentOffset.x - self.initialContentOffsetX,
                                      self.maxDragDistanceFromLeft);
  self.maxDragDistanceFromRight = fmax(self.collectionView.contentOffset.x - self.initialContentOffsetX,
                                       self.maxDragDistanceFromRight);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  self.indexOfMostExposedCellBeforeDragging = [self indexOfMostExposedCell];
  self.maxDragDistanceFromLeft = 0;
  self.maxDragDistanceFromRight = 0;
  self.initialContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollToIndex:(NSInteger)index
             velocity:(CGPoint)velocity
  targetContentOffset:(CGPoint *)targetContentOffset {
  [self stopDeceleration:targetContentOffset];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
  CGFloat predictedOffset = [self offsetByIndex:index];
  CGFloat duration = fabs(self.collectionView.contentOffset.x - predictedOffset) / (fabs(velocity.x) * 1000.0);
  duration = fclamp(duration, kDurationMin, kDurationMax);
  NSLog(@"Duration: %f", duration);
  __weak typeof(self) weakSelf = self;
  [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
    [weakSelf.collectionView scrollToItemAtIndexPath:indexPath
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
  } completion:nil];
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
  [self.collectionView scrollToItemAtIndexPath:indexPath
                              atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                      animated:animated];
}

- (void)stopDeceleration:(CGPoint *)targetContentOffset {
  *targetContentOffset = self.collectionView.contentOffset;
}

- (NSUInteger)indexOfMostExposedCell {
  NSUInteger dataSourceCount = self.dataSourceCategories.count > 0 ?
      self.dataSourceCategories.count : self.dataSourceItems.count;
  NSUInteger index = 0;
  CGFloat cumulativeSize = [self sizeOfNthCell:index totalCells:dataSourceCount];
  while (cumulativeSize < self.collectionView.contentOffset.x) {
    index++;
    cumulativeSize += [self sizeOfNthCell:index totalCells:dataSourceCount];
  };
  CGFloat fraction = (cumulativeSize - self.collectionView.contentOffset.x) / self.frame.size.width;
  // Most of the cell is hidden.
  if (fraction < 0.5) {
    index =  index + 1;
  }
  NSUInteger safeIndex = clamp(index, 0, dataSourceCount - 1);
  return safeIndex;
}

- (CGFloat)sizeOfNthCell:(NSUInteger)index
              totalCells:(NSUInteger)totalCells {
  CGSize itemSize = self.cellSize;
  if (index == 0) {
    return IndexViewControllerCoverInset + itemSize.width +
    IndexViewControllerCoverInset / 2;
  }
  if (index == totalCells - 1) {
    return IndexViewControllerCoverInset / 2 + itemSize.width +
    IndexViewControllerCoverInset;
  }
  return IndexViewControllerCoverInset / 2 + itemSize.width +
  IndexViewControllerCoverInset / 2;
}

- (CGFloat)offsetByIndex:(NSUInteger)index {
  CGFloat offset = self.cellSize.width * index;
  return offset;
}

@end
