import { combineReducers } from "redux";
import getUsers from "./getUsers";

export default combineReducers({
  users: getUsers,
});
