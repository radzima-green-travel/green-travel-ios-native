import React from 'react';

import {createStackNavigator} from '@react-navigation/stack';

import {AppMapScreen, ObjectDetailsScreen, ObjectsListScreen} from 'screens';

import {getAppHeaderOptions} from '../screenOptions';
import {useColorScheme} from 'core/hooks';
import {AppMapNavigatorParamsList} from 'core/types';

const Stack = createStackNavigator<AppMapNavigatorParamsList>();

export function AppMapNavigatior() {
  const colorScheme = useColorScheme();

  return (
    <Stack.Navigator
      screenOptions={{
        detachPreviousScreen: false,
        ...getAppHeaderOptions({colorScheme}),
        title: 'Карта',
      }}>
      <Stack.Screen
        options={{headerShown: false}}
        name="AppMap"
        component={AppMapScreen}
      />
      <Stack.Screen
        name="ObjectDetails"
        component={ObjectDetailsScreen}
        options={{headerShown: false}}
      />
      <Stack.Screen name="ObjectsList" component={ObjectsListScreen} />
    </Stack.Navigator>
  );
}
