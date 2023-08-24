import * as action from "./actionNames";
import regres from "../apis/regres";

export const getUsers = () => async (dispatch) => {
  regres
    .get("/users")
    .then((response) => {
      dispatch({
        type: action.GET_USERS,
        payload: response,
      });
    })
    .catch((err) => {
      console.error("getUsers", err);
    });
};
