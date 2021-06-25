import React, {useEffect, useMemo, useState, useCallback} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {navigationRef} from 'services/NavigationService';
import {MainNavigator} from './MainNavigator';
import {useDispatch, useSelector} from 'react-redux';
import {bootstrapStart} from 'core/reducers';
import {IState} from 'core/store';
import {View, StyleSheet, Animated, Easing, StatusBar} from 'react-native';
import {FONTS} from 'assets';
import RNBootSplash from 'react-native-bootsplash';

const SplasScreen = ({onAnimationEnd, onFadeStart}) => {
  const animatedValue = useMemo(() => new Animated.Value(0), []);
  const opacity = useMemo(() => new Animated.Value(1), []);

  useEffect(() => {
    setTimeout(() => {
      RNBootSplash.hide().then(() => {
        setTimeout(() => {
          onFadeStart?.();
        }, 300);
        Animated.sequence([
          Animated.timing(animatedValue, {
            toValue: 1,
            duration: 300,
            easing: Easing.out(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(opacity, {
            toValue: 0,
            duration: 300,
            easing: Easing.out(Easing.ease),
            useNativeDriver: true,
          }),
        ]).start(() => {
          onAnimationEnd();
        });
      });
    }, 300);
  }, [animatedValue, opacity, onAnimationEnd, onFadeStart]);
  return (
    <Animated.View
      style={{
        ...StyleSheet.absoluteFill,
        backgroundColor: '#fff',
        justifyContent: 'center',
        alignItems: 'center',
        opacity: opacity,
      }}>
      <Animated.Image
        style={{
          transform: [
            {
              translateX: animatedValue.interpolate({
                inputRange: [0, 1],
                outputRange: [0, -90],
              }),
            },
          ],
        }}
        source={require('./img/icon.png')}
      />

      <View
        style={{
          ...StyleSheet.absoluteFill,
          justifyContent: 'center',
          alignItems: 'center',
        }}>
        <Animated.Text
          style={{
            color: '#444444',
            fontSize: 36,
            fontFamily: FONTS.secondarySemibold,
            transform: [
              {scale: animatedValue},
              {
                translateX: animatedValue.interpolate({
                  inputRange: [0, 1],
                  outputRange: [0, 35],
                }),
              },
            ],
            opacity: animatedValue,
          }}>
          Radzima
        </Animated.Text>
      </View>
    </Animated.View>
  );
};

export function RootNavigator() {
  const dispatch = useDispatch();
  const [splashTransitionFinished, setSplashTransitionFinished] = useState(
    false,
  );
  const bootstrapFinished = useSelector(
    (state: IState) => state.bootsrap.finished,
  );

  useEffect(() => {
    dispatch(bootstrapStart());
  }, [dispatch]);

  const onAnimationEnd = useCallback(() => {
    setSplashTransitionFinished(true);
  }, []);

  const onFadeStart = useCallback(() => {
    StatusBar.pushStackEntry({
      barStyle: 'light-content',
      animated: true,
    });
  }, []);
  return (
    <NavigationContainer ref={navigationRef}>
      {bootstrapFinished && <MainNavigator />}
      {splashTransitionFinished ? null : (
        <SplasScreen
          onFadeStart={onFadeStart}
          onAnimationEnd={onAnimationEnd}
        />
      )}
    </NavigationContainer>
  );
}
