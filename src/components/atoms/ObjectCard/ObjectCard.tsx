import React, {memo, useCallback, useState} from 'react';
import {View, Text, TouchableOpacity, StyleProp, ViewStyle} from 'react-native';
import {Icon} from 'atoms';
import {styles} from './styles';
import FastImage from 'react-native-fast-image';
import {IExtendedObject} from 'core/types';

interface IProps {
  data: IExtendedObject;
  onPress?: () => void;
  containerStyle?: StyleProp<ViewStyle>;
  onIsFavoriteChange: (data: {objectId: string; needToAdd: boolean}) => void;
}

export const ObjectCard = memo(
  ({data, containerStyle, onPress, onIsFavoriteChange}: IProps) => {
    const [internalIsFavorite, setInternalIsFavorite] = useState(
      data.isFavorite,
    );
    const {cover, name, _id} = data;
    const onIsFavoriteChangeHandler = useCallback(() => {
      setInternalIsFavorite((prev) => {
        const nextValue = !prev;

        onIsFavoriteChange({
          objectId: _id,
          needToAdd: nextValue,
        });
        return nextValue;
      });
    }, [onIsFavoriteChange, _id]);

    return (
      <TouchableOpacity
        onPress={onPress}
        activeOpacity={0.8}
        style={[styles.cardContainer, containerStyle]}>
        <FastImage style={styles.image} source={{uri: cover}} />
        <View style={styles.cover} />
        <View style={styles.cardContentContainer}>
          <Text style={styles.title}>{name}</Text>
          {typeof internalIsFavorite === 'boolean' ? (
            <TouchableOpacity
              onPress={onIsFavoriteChangeHandler}
              hitSlop={{top: 15, left: 15, bottom: 15, right: 15}}
              activeOpacity={0.8}>
              <Icon
                name={internalIsFavorite ? 'bookmarkFilled' : 'bookmark'}
                width={20}
                height={20}
                color={'white'}
              />
            </TouchableOpacity>
          ) : null}
        </View>
      </TouchableOpacity>
    );
  },
);
