import React from 'react';
import {View} from 'react-native';
import {GeneralListItem} from 'molecules';
import {Icon, SettingsSectionTitle} from 'atoms';
import {screenOptions} from './screenOptions';
import {useProfile} from './hooks';

export const Profile = () => {
  const {t, styles, onAuthorisationItemPress, isAuthorized, userEmail} =
    useProfile();

  return (
    <View style={styles.container}>
      <View style={styles.authItemContainer}>
        <GeneralListItem
          size="M"
          onPress={onAuthorisationItemPress}
          title={
            isAuthorized ? t('authorized.title') : t('notAuthorrized.title')
          }
          subtitle={isAuthorized ? userEmail : t('notAuthorrized.subtitle')}
          renderLeftElement={<Icon name="defaultAcc" size={60} />}
        />
      </View>

      <SettingsSectionTitle text="Настройки" />
      <GeneralListItem
        position="top"
        onPress={() => {}}
        title={t('dataAndMemory')}
        renderLeftElement={<Icon name="memoryNData" size={30} />}
      />
      <GeneralListItem
        position="middle"
        onPress={() => {}}
        title={t('language')}
        renderLeftElement={<Icon name="language" size={30} />}
      />
      <GeneralListItem
        position="bottom"
        onPress={() => {}}
        title={t('theme')}
        renderLeftElement={<Icon name="theme" size={30} />}
      />
    </View>
  );
};

Profile.screenOptions = screenOptions;