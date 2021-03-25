import {useThemeStyles} from 'core/hooks';
import React, {memo} from 'react';
import {useTranslation} from 'react-i18next';
import {Pressable, View, Text} from 'react-native';
import {themeStyles} from './styles';
import {tryOpenURL} from 'core/helpers';

interface IProps {
  url: string;
}

export const ObjectDetailsSiteLink = memo(({url}: IProps) => {
  const {t} = useTranslation('objectDetails');
  const styles = useThemeStyles(themeStyles);

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{t('offSite')}</Text>
      <Pressable onPress={() => tryOpenURL(url)}>
        <Text style={styles.text}>{url}</Text>
      </Pressable>
    </View>
  );
});