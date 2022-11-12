import {BottomMenu, ClusterMap} from 'atoms';
import React, {useCallback, useEffect} from 'react';
import {InteractionManager, StyleProp, View} from 'react-native';
import MapBox, {
  FillLayerStyle,
  LineLayerStyle,
  SymbolLayerStyle,
} from '@react-native-mapbox-gl/maps';
import {
  useOnRequestSuccess,
  useRequestErrorAlert,
  useStatusBar,
} from 'core/hooks';
import {
  BackCircleButton,
  ObjectDetailsMapButtons,
  ObjectDetailsMapBottomMenu,
} from 'molecules';
import {mapService} from 'services/MapService';

import {
  clearObjectDetailsMapDirection,
  showObjectDetailsMapDirectionRequest,
} from 'core/reducers';
import {hapticFeedbackService} from 'services/HapticFeedbackService';
import {FeatureCollection, LineString, Point} from '@turf/helpers';
import {useObjectDetailsMap} from './hooks';

const mapPin = require('assets/images/map-pin.png');

const images = {
  mapPin,
};

export const ObjectDetailsMap = () => {
  const {
    theme,
    direction,
    bottom,
    top,
    camera,
    data,
    openMenu,
    dispatch,
    centerCoordinate,
    unfocusUserLocation,
    onMarkerPress,
    bounds,
    map,
    userLocationProps,
    layersStyles,
    dataShapeSource,
    menuProps,
    onShowLocationPress,
    isUserLocationFocused,
    belongsToSubtitle,
    onMenuButtonPress,
    loading,
    isDirectionShowed,
    onBackPress,
  } = useObjectDetailsMap();

  useStatusBar(theme);

  useRequestErrorAlert(showObjectDetailsMapDirectionRequest, 'common');

  useOnRequestSuccess(showObjectDetailsMapDirectionRequest, () => {
    const directionBounds = mapService.getBoundsFromGeoJSON(direction, {
      bottom: 200 + bottom,
      top: 30 + top,
    });
    camera.current?.fitBounds(...directionBounds);
  });

  useOnRequestSuccess(
    showObjectDetailsMapDirectionRequest,
    useCallback(() => {
      hapticFeedbackService.trigger('notificationSuccess');
    }, []),
  );

  useEffect(() => {
    if (data) {
      InteractionManager.runAfterInteractions(() => {
        openMenu();
      });
    }
  }, [data, openMenu]);

  useEffect(() => {
    return () => {
      dispatch(clearObjectDetailsMapDirection());
    };
  }, [dispatch]);

  return (
    <View style={{flex: 1}}>
      <ClusterMap
        attributionPosition={{bottom: 40, right: 30}}
        centerCoordinate={centerCoordinate}
        onRegionWillChange={unfocusUserLocation}
        onShapePress={onMarkerPress}
        bounds={bounds}
        ref={map}
        cameraRef={camera}>
        {userLocationProps.visible ? (
          <MapBox.UserLocation
            renderMode="native"
            minDisplacement={10}
            {...userLocationProps}
          />
        ) : null}

        {direction ? (
          <MapBox.ShapeSource
            id="directionSource"
            shape={direction as unknown as LineString}>
            <MapBox.LineLayer
              id="directionFillBackground"
              belowLayerID="singlePoint"
              style={
                layersStyles.directionBackground as StyleProp<LineLayerStyle>
              }
            />
            <MapBox.LineLayer
              id="directionFill"
              belowLayerID="singlePoint"
              style={layersStyles.direction as StyleProp<LineLayerStyle>}
            />
          </MapBox.ShapeSource>
        ) : null}

        {data?.area ? (
          <MapBox.ShapeSource id="area" shape={data?.area}>
            <MapBox.FillLayer
              id="areaFill"
              style={layersStyles.area as StyleProp<FillLayerStyle>}
            />
            <MapBox.LineLayer
              id="areaStroke"
              style={layersStyles.areaStroke as StyleProp<LineLayerStyle>}
            />
          </MapBox.ShapeSource>
        ) : null}

        {data?.routes ? (
          <MapBox.ShapeSource id="routeSource" shape={data?.routes}>
            <MapBox.LineLayer
              id="routeFill"
              style={layersStyles.route as StyleProp<LineLayerStyle>}
            />
          </MapBox.ShapeSource>
        ) : null}

        {dataShapeSource ? (
          <>
            <MapBox.Images images={images} />
            <MapBox.ShapeSource
              id="objectPinSource"
              shape={dataShapeSource as FeatureCollection<Point>}>
              <MapBox.SymbolLayer
                id="singlePoint"
                style={
                  layersStyles.objectDetailsPin as StyleProp<SymbolLayerStyle>
                }
              />
            </MapBox.ShapeSource>
          </>
        ) : null}
      </ClusterMap>
      <ObjectDetailsMapButtons
        bottomMenuPosition={menuProps.animatedPosition}
        onShowLocationPress={onShowLocationPress}
        isUserLocationFocused={isUserLocationFocused}
        botttomInset={bottom}
      />
      <BottomMenu {...menuProps}>
        <ObjectDetailsMapBottomMenu
          data={data}
          belongsToSubtitle={belongsToSubtitle}
          onHideEnd={() => {}}
          bottomInset={bottom}
          onButtonPress={onMenuButtonPress}
          loading={loading}
          isDirectionShowed={!!isDirectionShowed}
        />
      </BottomMenu>
      <BackCircleButton onPress={onBackPress} />
    </View>
  );
};