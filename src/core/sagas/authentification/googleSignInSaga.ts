import {call, put} from 'redux-saga/effects';
import {googleSigninSuccess, googleSigninFailure} from 'core/reducers';
import {createAuthHubChannel} from './createAuthHubChannel';
import {CognitoUserWithAttributes} from 'core/types';

import {CognitoHostedUIIdentityProvider} from '@aws-amplify/auth';
import {socialSignInSaga} from './socialSignInSaga';

export function* googleSignInSaga() {
  const channel = createAuthHubChannel();

  try {
    const user: CognitoUserWithAttributes = yield call(socialSignInSaga, {
      provider: CognitoHostedUIIdentityProvider.Google,
      authChannel: channel,
    });

    yield put(googleSigninSuccess(user.attributes));
  } catch (e) {
    yield put(googleSigninFailure(e as Error));
  } finally {
    channel.close();
  }
}