import React from 'react';
import {COLORS} from 'assets';
import {Icon} from 'atoms';
import {GeneralListItem} from 'molecules';
import {View} from 'react-native';
import {useProfileSettingsLanguage} from './hooks';
import {useTranslation} from 'react-i18next';
import {useThemeStyles} from 'core/hooks';
import {themeStyles} from './styles';

export const ProfileSettingsLanguage = () => {
  const {t} = useTranslation('profile');
  const styles = useThemeStyles(themeStyles);

  const {changeLanguage, userLanguage, getItemDisabled, getItemLoading} =
    useProfileSettingsLanguage();

  return (
    <View style={styles.container}>
      <GeneralListItem
        position="top"
        loading={getItemLoading(null)}
        disabled={getItemDisabled(null)}
        onPress={() => changeLanguage(null)}
        title={t('systemLanguage')}
        renderRightElement={
          !userLanguage && (
            <Icon color={COLORS.apple} name="CheckXL" size={24} />
          )
        }
      />
      <GeneralListItem
        position="middle"
        loading={getItemLoading('en')}
        disabled={getItemDisabled('en')}
        onPress={() => changeLanguage('en')}
        title={'English'}
        renderRightElement={
          userLanguage === 'en' && (
            <Icon color={COLORS.apple} name="CheckXL" size={24} />
          )
        }
      />
      <GeneralListItem
        position="middle"
        loading={getItemLoading('ru')}
        disabled={getItemDisabled('ru')}
        onPress={() => changeLanguage('ru')}
        title={'Русский'}
        renderRightElement={
          userLanguage === 'ru' && (
            <Icon color={COLORS.apple} name="CheckXL" size={24} />
          )
        }
      />
      <GeneralListItem
        position="bottom"
        loading={getItemLoading('zh')}
        disabled={getItemDisabled('zh')}
        onPress={() => changeLanguage('zh')}
        title={'中國人'}
        renderRightElement={
          userLanguage === 'zh' && (
            <Icon color={COLORS.apple} name="CheckXL" size={24} />
          )
        }
      />
    </View>
  );
};
