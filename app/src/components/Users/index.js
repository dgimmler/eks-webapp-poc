import React, { Component } from "react";
import { connect } from "react-redux";
import { getUsers } from "../../actions";

import "./Users.css";

class Users extends Component {
  componentDidMount() {
    this.props.getUsers();
  }

  renderUser(user) {
    return (
      <tr key={user.id}>
        <td className="align-middle">
          <img src={user.avatar}></img>
        </td>
        <td className="align-middle">
          {user.first_name} {user.last_name}
        </td>
        <td className="align-middle">{user.email}</td>
      </tr>
    );
  }

  renderUsers(users) {
    users = users || []; // handle undefined
    let userDivs = [];
    for (let i = 0; i < users.length; i++)
      userDivs.push(this.renderUser(users[i]));
    return <tbody>{userDivs}</tbody>;
  }

  renderTable() {
    return (
      <table className="table">
        <thead>
          <tr>
            <th scope="col"></th>
            <th scope="col">Name</th>
            <th scope="col">Email</th>
          </tr>
        </thead>
        {this.renderUsers(this.props.users)}
      </table>
    );
  }

  render() {
    return (
      <div className="background">
        <div className="users card col-10 col-sm-8 col-xl-6 offset-1 offset-sm-2 offset-xl-3">
          <h1>Users</h1>
          <div className="users-list col-10 offset-1">{this.renderTable()}</div>
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {
  return {
    users: state.users,
  };
};

export default connect(mapStateToProps, {
  getUsers,
})(Users);
