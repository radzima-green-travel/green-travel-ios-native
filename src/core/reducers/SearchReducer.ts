import {createAction, createReducer, ActionType} from 'typesafe-actions';
import {IExtendedObjectWithCategoryData} from '../types';
import {ACTIONS} from '../constants';
import {uniqBy} from 'lodash';

interface IDefaultState {
  history: IExtendedObjectWithCategoryData[];
  inputValue: string;
}

const initialState: IDefaultState = {
  history: [],
  inputValue: '',
};

export const setSearchInputValue = createAction(ACTIONS.SET_SEARCH_INPUT_VALUE)<
  string
>();

export const addObjectToSearchHistory = createAction(
  ACTIONS.ADD_OBJECT_TO_SEARCH_HISTORY,
)<IExtendedObjectWithCategoryData>();

const actions = {
  addObjectToSearchHistory,
  setSearchInputValue,
};

export const searchReducer = createReducer<
  IDefaultState,
  ActionType<typeof actions>
>(initialState)
  .handleAction(setSearchInputValue, (state, {payload}) => ({
    ...state,
    inputValue: payload,
  }))
  .handleAction(addObjectToSearchHistory, (state, {payload}) => ({
    ...state,
    history: uniqBy([...state.history, payload], '_id'),
  }));