import React, {useRef, useState, useEffect, useCallback} from 'react';
import {ClusterMap, ClusterMapShape} from 'atoms';
import {
  selectMapMarkers,
  selectBounds,
  selectSelectedMapMarker,
  createMarkerFromObject,
  selectMapFilters,
} from 'core/selectors';
import {useSelector} from 'react-redux';
import {View} from 'react-native';

import {Portal} from 'atoms';
import {styles, selectedPointStyle} from './styles';
import {IExtendedObjectWithCategoryData, IMapFilter} from 'core/types';
import MapBox from '@react-native-mapbox-gl/maps';
import {
  AppMapBottomMenu,
  AppMapBottomMenuRef,
  AppMapBottomSearchMenuRef,
  AppMapBottomSearchMenu,
  AppMapFilters,
  AppMapButtons,
} from 'molecules';
import {
  useDarkStatusBar,
  useSearchList,
  useFocusToUserLocation,
} from 'core/hooks';
import {IState} from 'core/store';
import {useSafeAreaInsets} from 'react-native-safe-area-context';
import {xorBy} from 'lodash';
import {IProps} from './types';
type SelecteMarker = ReturnType<typeof createMarkerFromObject>;

export const AppMap = ({navigation}: IProps) => {
  const mapFilters = useSelector(selectMapFilters);

  const [selectedMarkerId, setSelectedMarkerId] = useState<string | null>(null);

  const [selectedMarker, setSelectedMarker] = useState<SelecteMarker | null>(
    () => createMarkerFromObject(null),
  );
  const [selectedFilters, setSelectedFilters] = useState<IMapFilter[]>([]);

  const selected = useSelector((state: IState) =>
    selectSelectedMapMarker(state, selectedMarkerId),
  );

  const {bottom} = useSafeAreaInsets();
  const {
    data,
    isHistoryVisible,
    onTextChange,
    addToHistory,
    clearInput,
  } = useSearchList();
  const markers = useSelector((state: IState) =>
    selectMapMarkers(state, selectedFilters),
  );
  const bounds = useSelector((state: IState) =>
    selectBounds(state, selectedFilters),
  );

  const camera = useRef<MapBox.Camera>(null);
  const bottomMenu = useRef<AppMapBottomMenuRef>(null);
  const bottomSearchMenu = useRef<AppMapBottomSearchMenuRef>(null);

  useEffect(() => {
    if (selected) {
      setSelectedMarker(createMarkerFromObject(selected));
      bottomMenu.current?.show();
    }
  }, [selected]);

  const onPress = useCallback(() => {
    setSelectedMarker(createMarkerFromObject(null));
    bottomMenu.current?.hide();
  }, []);

  const onShapePress = useCallback(
    (itemData: IExtendedObjectWithCategoryData) => {
      camera.current?.moveTo(itemData.location.coordinates, 500);
      setSelectedMarkerId(itemData._id);
    },
    [],
  );

  const navigateToObjectDetails = useCallback(
    ({_id, category}: IExtendedObjectWithCategoryData) => {
      bottomMenu.current?.hide();
      setSelectedMarker(createMarkerFromObject(null));
      navigation.push('ObjectDetails', {categoryId: category, objectId: _id});
    },
    [navigation],
  );

  const onSearchItemPress = useCallback(
    (itemData: IExtendedObjectWithCategoryData) => {
      camera.current?.setCamera({
        centerCoordinate: itemData.location.coordinates,
        zoomLevel: 7,
        animationDuration: 1000,
      });
      addToHistory(itemData);
      setSelectedMarkerId(itemData._id);
      clearInput();
    },
    [addToHistory, clearInput],
  );

  const onMenuHideEnd = useCallback(() => {
    setSelectedMarkerId(null);
  }, []);

  const onFilterSelect = useCallback((item: IMapFilter) => {
    setSelectedFilters((prev) => {
      return xorBy(prev, [item], 'categoryId');
    });
  }, []);

  useEffect(() => {
    if (bounds) {
      camera.current?.fitBounds(...bounds);
    }
  }, [bounds]);

  const resetFilters = useCallback(() => {
    setSelectedFilters([]);
  }, []);

  const {focusToUserLocation, ...userLocationProps} = useFocusToUserLocation(
    camera,
  );
  useDarkStatusBar();
  return (
    <View style={styles.container}>
      <ClusterMap
        bounds={bounds}
        ref={camera}
        onShapePress={onShapePress}
        onPress={onPress}>
        {userLocationProps.visible ? (
          <MapBox.UserLocation {...userLocationProps} />
        ) : null}
        <ClusterMapShape markers={markers} />

        <MapBox.ShapeSource
          id={'selectedPointShapeSource'}
          shape={selectedMarker}>
          <MapBox.SymbolLayer id={'selectedPoint'} style={selectedPointStyle} />
        </MapBox.ShapeSource>
      </ClusterMap>
      <Portal>
        <AppMapBottomMenu
          data={selected}
          ref={bottomMenu}
          onHideEnd={onMenuHideEnd}
          bottomInset={bottom}
          onGetMorePress={navigateToObjectDetails}
        />
        <AppMapBottomSearchMenu
          isHistoryVisible={isHistoryVisible}
          data={data}
          ref={bottomSearchMenu}
          onItemPress={onSearchItemPress}
          onTextChange={onTextChange}
          bottomInset={bottom}
        />
      </Portal>
      <AppMapButtons
        onShowLocationPress={focusToUserLocation}
        onSearchPress={() => bottomSearchMenu.current?.show()}
      />
      <AppMapFilters
        onFilterSelect={onFilterSelect}
        resetFilters={resetFilters}
        selectedFilters={selectedFilters}
        filters={mapFilters}
      />
    </View>
  );
};
