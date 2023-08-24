import React from "react";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import Users from "../Users";

import "bootstrap/dist/css/bootstrap.css";
import "./App.css";

const App = () => {
  return (
    <div>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Users />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
};

export default App;
