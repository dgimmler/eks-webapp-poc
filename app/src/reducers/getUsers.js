import * as actionNames from "../actions/actionNames";

export default (state = [], action) => {
  switch (action.type) {
    case actionNames.GET_USERS:
      return action.payload.data.data;
    default:
      return state;
  }
};
