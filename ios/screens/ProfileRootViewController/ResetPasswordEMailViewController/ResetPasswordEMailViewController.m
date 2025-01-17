//
//  ResetPasswordEMailViewController.m
//  greenTravel
//
//  Created by Alex K on 15.06.22.
//

#import "ResetPasswordEMailViewController.h"
#import "CommonTextField.h"
#import "CommonButton.h"
#import "Typography.h"
#import "UserController.h"
#import "UserModel.h"
#import "UserModelConstants.h"
#import "ResetPasswordPassCodeViewController.h"
#import "CommonFormConstants.h"
#import "Colors.h"

@interface ResetPasswordEMailViewController ()

@property(strong, nonatomic) UILabel *hintLabel;
@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) CommonButton *buttonSubmit;
@property(strong, nonatomic) UIButtonHighlightable *buttonBackToSignIn;
@property(assign, nonatomic) BOOL shownKeyboard;
@property(assign, nonatomic) BOOL shouldNavigateToCodeScreen;
@property(assign, nonatomic) BOOL initialLoad;

@end

@implementation ResetPasswordEMailViewController

- (void)viewDidLayoutSubviews {
  [self.hintLabel setPreferredMaxLayoutWidth:self.view.frame.size.width -
   CommonFormMinContentInset * 2];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NSLocalizedString(@"ResetPasswordEMailScreenTitle", @"");

  self.titleLabel = [[UILabel alloc] init];
  NSAttributedString *header = [[Typography get] formHeader:NSLocalizedString(@"ResetPasswordEMailScreenHeader", @"")];
  [self.titleLabel setAttributedText:header];
  [self.titleLabel setNumberOfLines:0];
  [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
  [self.contentView addSubview:self.titleLabel];
  self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

  [NSLayoutConstraint activateConstraints:@[
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [self.titleLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor],
    [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor],
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:CommonFormContentTopOffset],
  ]];

  self.hintLabel = [[UILabel alloc] init];
  NSAttributedString *hint = [[Typography get] codeConfirmationHint:NSLocalizedString(@"ResetPasswordEMailScreenHint", @"")];
  [self.hintLabel setAttributedText:hint];
  [self.hintLabel setNumberOfLines:0];
  [self.hintLabel setTextAlignment:NSTextAlignmentCenter];
  [self.contentView addSubview:self.hintLabel];
  self.hintLabel.translatesAutoresizingMaskIntoConstraints = NO;

  [NSLayoutConstraint activateConstraints:@[
    [self.hintLabel.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [self.hintLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.leadingAnchor],
    [self.hintLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor],
    [self.hintLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:20.0],
  ]];

  self.textFieldMail = [[CommonTextField alloc] initWithImageName:@"textfield-mail"
                                                     keyboardType:UIKeyboardTypeEmailAddress
                                                      placeholder:NSLocalizedString(@"ProfileScreenPlaceholderEMail", @"")];
  self.textFieldMail.textField.delegate = self;
  [self.textFieldMail.textField setTextContentType:UITextContentTypeEmailAddress];
  [self.contentView addSubview:self.textFieldMail];
  self.textFieldMail.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
      [self.textFieldMail.topAnchor constraintEqualToAnchor:self.hintLabel.bottomAnchor constant:20.0],
      [self.textFieldMail.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
      [self.textFieldMail.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
  ]];

  self.buttonSubmit = [[CommonButton alloc] initWithTarget:self
                                                    action:@selector(onSubmit:)
                                                     label:NSLocalizedString(@"CodeConfirmationScreenSubmit", @"")];
  self.buttonSubmit.translatesAutoresizingMaskIntoConstraints = NO;
  [self.contentView addSubview:self.buttonSubmit];

  [NSLayoutConstraint activateConstraints:@[
    [self.buttonSubmit.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
    [self.buttonSubmit.topAnchor constraintEqualToAnchor:self.textFieldMail.bottomAnchor constant:CommonFormTextFieldAndButtonSpace],
    [self.buttonSubmit.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
    [self.buttonSubmit.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
    [self.buttonSubmit.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:CommonFormButtonBottomSpace],
  ]];

  self.buttonBackToSignIn = [[UIButtonHighlightable alloc] init];
	self.buttonBackToSignIn.translatesAutoresizingMaskIntoConstraints = NO;
	[self.buttonBackToSignIn setTintColor:[Colors get].buttonTextTint];
	NSAttributedString *label = [[Typography get] textButtonLabel:NSLocalizedString(@"ResetPasswordBackToSignInButtonTitle", @"")];
	[self.buttonBackToSignIn setAttributedTitle:label forState:UIControlStateNormal];
	[self.buttonBackToSignIn addTarget:self action:@selector(backToSignIn) forControlEvents:UIControlEventTouchUpInside];

	[self.contentView addSubview:self.buttonBackToSignIn];

	[NSLayoutConstraint activateConstraints:@[
		[self.buttonBackToSignIn.centerXAnchor constraintEqualToAnchor:self.buttonSubmit.centerXAnchor],
		[self.buttonBackToSignIn.topAnchor constraintEqualToAnchor:self.buttonSubmit.bottomAnchor constant:25.0]
	]];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!self.shownKeyboard) {
    self.shownKeyboard = YES;
    [self.textFieldMail becomeFirstResponder];
  }
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
}

- (void)backToSignIn {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)onUserModelStateTransitionFrom:(UserModelState)prevState toCurrentState:(UserModelState)currentState {
  dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
      if (currentState == UserModelStatePasswordEmailInProgress) {
        [self enableLoadingIndicator:YES];
        return;
      }
      if (prevState == UserModelStatePasswordResetConfirmCodeNotSent && currentState == UserModelStatePasswordResetConfirmCodeInProgress) {
        [self enableLoadingIndicator:YES];
        return;
      }
      if (currentState == UserModelStatePasswordResetConfirmCodeInProgress) {
        [self enableLoadingIndicator:YES];
        return;
      }
      if (prevState == UserModelStatePasswordEmailInProgress && currentState == UserModelStateFetched) {
        [self enableLoadingIndicator:NO];
        return;
      }
      if (prevState == UserModelStatePasswordResetConfirmCodeInProgress && currentState == UserModelStatePasswordResetConfirmCodeNotSent) {
        [self enableLoadingIndicator:NO];
        return;
      }
      if (prevState == UserModelStatePasswordEmailInProgress && currentState == UserModelStatePasswordResetConfirmCodeNotSent &&
          self.shouldNavigateToCodeScreen) {
        ResetPasswordPassCodeViewController *resetPasswordPassCodeViewController =
        [[ResetPasswordPassCodeViewController alloc] initWithController:self.userController
                                                                  model:self.userModel];
        [self.navigationController pushViewController:resetPasswordPassCodeViewController
                                             animated:YES];
        self.shouldNavigateToCodeScreen = NO;
        return;
      }
      if (prevState == UserModelStatePasswordEmailInProgress && currentState == UserModelStatePasswordResetConfirmCodeNotSent &&
          !self.shouldNavigateToCodeScreen) {
        [self enableLoadingIndicator:NO];
        return;
      }
    });
  });
}

- (void)onSubmit:(CommonButton *)sender {
  self.shouldNavigateToCodeScreen = YES;
  [self.userController initiateResetPassword:self.textFieldMail.textField.text];
  [self.view endEditing:YES];
}

@end
