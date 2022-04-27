import React from 'react';

import {AuthentificationScreen, ProfileScreen} from 'screens';

import {useTranslation} from 'react-i18next';
import {useScreenOptions} from '../screenOptions';
import {ProfileNavigatorParamsList} from 'core/types';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {defaultTransition} from '../transition';

const Stack = createNativeStackNavigator<ProfileNavigatorParamsList>();

export function ProfileNavigator() {
  const screenOptions = useScreenOptions();
  const {t} = useTranslation('common');

  return (
    <Stack.Navigator
      screenOptions={{
        ...screenOptions,
        title: t('tabs.profile'),
        animation: defaultTransition,
      }}>
      <Stack.Screen
        name="Authentification"
        component={AuthentificationScreen}
      />
      <Stack.Screen name="Profile" component={ProfileScreen} />
    </Stack.Navigator>
  );
}