//
//  AuthErrors.swift
//  greenTravel
//
//  Created by Alex K on 14.06.22.
//

import Foundation

@objc enum AmplifyBridgeError: Int {
  case AuthErrorFetchSessionFailed = 1
  case AuthErrorSignInFailed
  case AuthErrorNotSignedIn
  case AuthErrorResetPasswordFailed
  case AuthErrorResetPasswordConfirmFailed
  case AuthErrorCodeMismatch
  case AuthErrorInvalidPassword
  case AuthErrorUserNotFound
}

let AuthErrorDomain = "app.radzima"