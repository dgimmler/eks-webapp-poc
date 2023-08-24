import { render, screen, waitFor } from "@testing-library/react";
import configureStore from "redux-mock-store";
import { Provider } from "react-redux";
import thunk from "redux-thunk";

import { getUsers } from "./actions";
import * as action from "./actions/actionNames";
import App from "./components/App/index";

const mockStore = configureStore([thunk]);
jest.mock("axios", () => {
  return {
    create: () => {
      return {
        get: () => {
          return Promise.resolve({ data: {} });
        },
        catch: () => {
          return Promise.reject();
        },
      };
    },
  };
});

test("should render the data from Redux state", () => {
  const store = mockStore({
    users: [
      {
        id: 2,
        email: "janet.weaver@reqres.in",
        first_name: "Janet",
        last_name: "Weaver",
        avatar: "https://reqres.in/img/faces/2-image.jpg",
      },
    ],
  });

  render(
    <Provider store={store}>
      <App />
    </Provider>
  );

  const dataElement = screen.getByText("Janet Weaver");
  expect(dataElement).toBeInTheDocument();
});

test("should dispatch the correct action", async () => {
  const store = mockStore({
    users: [],
  });

  render(
    <Provider store={store}>
      <App />
    </Provider>
  );

  store.dispatch(getUsers());

  await waitFor(() => {
    expect(store.getActions()[0]).toEqual(
      expect.objectContaining({
        type: action.GET_USERS,
      })
    );
  });
});
