import React, {useRef, useState, useEffect, useCallback} from 'react';
import {ClusterMap, ClusterMapShape} from 'atoms';
import {selectMapMarkers, selectBounds, selectMarker} from 'core/selectors';
import {useSelector} from 'react-redux';
import {View, Text} from 'react-native';
import BottomSheet from 'reanimated-bottom-sheet';
import {Button as CustomButton, Portal} from 'atoms';
import {styles} from './styles';
import {IObject} from 'core/types';
import MapBox from '@react-native-mapbox-gl/maps';

export const AppMap = () => {
  const bounds = useSelector(selectBounds);
  const [selected, setSelected] = useState<IObject | null>(null);
  const markers = useSelector(selectMapMarkers);
  const selectedMarker = useSelector(() => selectMarker(selected));
  const bs = useRef<BottomSheet>(null);
  const rendnerInner = () => {
    return (
      <View style={styles.bottomMenuContainer}>
        <Text style={styles.bottomMenuText}>{selected?.name}</Text>
        <CustomButton>Узнать больше</CustomButton>
      </View>
    );
  };

  useEffect(() => {
    if (selected) {
      bs.current?.snapTo(1);
    }
  }, [selected]);

  const onMarkerPress = useCallback(({isClustered, data}) => {
    if (!isClustered) {
      setSelected(data);
    }
  }, []);

  return (
    <View style={styles.container}>
      <ClusterMap
        onPress={useCallback(() => {
          bs.current?.snapTo(0);
        }, [])}
        bounds={bounds}>
        <ClusterMapShape markers={markers} onMarkerPress={onMarkerPress} />

        <MapBox.ShapeSource
          id={'selectedPointShapeSource'}
          shape={selectedMarker}>
          <MapBox.SymbolLayer
            id={'selectedPoint'}
            style={{
              iconImage: ['get', 'icon_image'],
              iconSize: 1,
              iconAllowOverlap: true,
            }}
          />
        </MapBox.ShapeSource>
      </ClusterMap>
      <Portal>
        <BottomSheet
          onCloseEnd={() => {
            setSelected(null);
          }}
          borderRadius={15}
          ref={bs}
          snapPoints={[0, 150]}
          renderContent={rendnerInner}
          initialSnap={0}
          enabledGestureInteraction={false}
        />
      </Portal>
    </View>
  );
};
