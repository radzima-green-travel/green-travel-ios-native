//
//  Typography.h
//  GreenTravel
//
//  Created by Alex K on 1/17/21.
//  Copyright © 2021 Alex K. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor;

NS_ASSUME_NONNULL_BEGIN

@interface Typography : NSObject

+ (instancetype)get;

- (NSAttributedString *)mainTextLink:(NSString *)input;
- (NSAttributedString *)mainText:(NSString *)input;
- (NSAttributedString *)formHeader:(NSString *)input;
- (NSAttributedString *)codeConfirmationHint:(NSString *)input;
- (NSAttributedString *)textButtonLabel:(NSString *)input;
- (NSAttributedString *)makeProfileTableViewCellMainTextLabelForSettingsCell:(NSString *)input;
- (NSAttributedString *)makeProfileTableViewCellSubTextLabelForSettingsCell:(NSString *)input;
- (NSAttributedString *)makeProfileTableViewCellMainTextLabelForAuthCell:(NSString *)input;
- (NSAttributedString *)makeProfileTableViewCellSubTextLabelForAuthCell:(NSString *)input;
- (NSAttributedString *)settingsCellTitle:(NSString *)input;
- (NSAttributedString *)settingsCellTitleDanger:(NSString *)input;
- (NSAttributedString *)settingsCellSubTitle:(NSString *)input;

@end

NS_ASSUME_NONNULL_END
