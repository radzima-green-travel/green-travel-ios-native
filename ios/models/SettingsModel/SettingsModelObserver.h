//
//  UserModelObserver.h
//  greenTravel
//
//  Created by Alex K on 24.05.22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SettingsGroup;
@class SettingsEntry;
@class SettingsScreen;

@protocol SettingsModelObserver <NSObject>

- (void)onSettingsModelTreeChange:(NSMutableArray<SettingsGroup *> *) tree;
- (void)onSettingsModelEntryChange:(SettingsEntry *)entry;
- (void)onSettingsModelGroupChange:(SettingsGroup *)group;
- (void)onSettingsModelScreenChange:(SettingsScreen *)screen;

@end

NS_ASSUME_NONNULL_END
