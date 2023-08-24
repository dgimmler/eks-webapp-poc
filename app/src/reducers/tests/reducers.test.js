import getUsers from "../getUsers";
import * as actionNames from "../../actions/actionNames";
import expect from "expect";

describe("getUsers reducer", () => {
  it("should return the initial state", () => {
    expect(getUsers(undefined, {})).toEqual([]);
  });

  it("should handle GET_USERS", () => {
    expect(
      getUsers(
        {},
        {
          type: actionNames.GET_USERS,
          payload: {
            data: {
              data: [
                {
                  id: 2,
                  email: "janet.weaver@reqres.in",
                  first_name: "Janet",
                  last_name: "Weaver",
                  avatar: "https://reqres.in/img/faces/2-image.jpg",
                },
              ],
            },
          },
        }
      )
    ).toEqual([
      {
        id: 2,
        email: "janet.weaver@reqres.in",
        first_name: "Janet",
        last_name: "Weaver",
        avatar: "https://reqres.in/img/faces/2-image.jpg",
      },
    ]);
  });
});
