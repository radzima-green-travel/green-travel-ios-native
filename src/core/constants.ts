export enum ACTIONS {
  BOOTSTRAP_START = 'BOOTSTRAP_START',
  BOOTSTRAP_FINISH = 'BOOTSTRAP_FINISH',
  CLEAR_ERROR_BY_ACTION_TYPE = 'CLEAR_ERROR_BY_ACTION_TYPE',
  CLEAR_SUCCESS_BY_ACTION_TYPE = 'CLEAR_SUCCESS_BY_ACTION_TYPE',

  GET_HOME_DATA_REQUEST = 'GET_HOME_DATA_REQUEST',
  GET_HOME_DATA_SUCCESS = 'GET_HOME_DATA_SUCCESS',
  GET_HOME_DATA_FAILURE = 'GET_HOME_DATA_FAILURE',

  ADD_TO_FAVORITE = 'ADD_TO_FAVORITE',
  REMOVE_FROM_FAVORITE = 'REMOVE_FROM_FAVORITE',

  SET_SEARCH_INPUT_VALUE = 'SET_SEARCH_INPUT_VALUE',
  ADD_OBJECT_TO_SEARCH_HISTORY = 'ADD_OBJECT_TO_SEARCH_HISTORY',
}

export const DEFAULT_BOUNDS = {
  ne: [110.07385416701771, 85.05112862791776],
  sw: [-110.07385416703308, -85.05112862791907],
  paddingLeft: 30,
  paddingRight: 30,
};

export enum MAP_PINS {
  BICYCLE_ROUTE = 'bicycle-route',
  OBJECT = 'object',
  HISTORICAL_PLACE = 'historical-place',
  EXCURSION_PIN = 'excursion-pin',
  WALKING_ROUTES = 'walking-routes',
  EMPTY_BIG = 'empty-big',
  EMPTY = 'empty',
  SELECTED_POSTFIX = '-black',
}

export const PADDING_HORIZONTAL = 16;

import {IconsNames} from 'atoms/Icon/IconsNames';

export const ICONS_MATCHER = {
  [MAP_PINS.BICYCLE_ROUTE]: 'strokeBike' as IconsNames,
  [MAP_PINS.HISTORICAL_PLACE]: 'strokeChurch' as IconsNames,
  [MAP_PINS.WALKING_ROUTES]: 'strokeFootprint' as IconsNames,
  [MAP_PINS.EXCURSION_PIN]: 'strokeFlag' as IconsNames,
  [MAP_PINS.OBJECT]: 'strokeForest' as IconsNames,
};
