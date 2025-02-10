// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract UserManagement is Ownable {
    enum Role { None, Patient, Hospital }

    struct User {
        Role role;
        bool isVerified;
        string metadataHash;
    }

    mapping(address => User) internal users;

    event UserRegistered(address indexed user, Role role);
    event UserVerified(address indexed user);
    event UserUnverified(address indexed user);

    constructor() Ownable(msg.sender) {}

    modifier onlyVerifiedPatient() {
        require(users[msg.sender].isVerified && users[msg.sender].role == Role.Patient, "Unauthorized: Not a verified patient");
        _;
    }

    modifier onlyVerifiedHospital() {
        require(users[msg.sender].isVerified && users[msg.sender].role == Role.Hospital, "Unauthorized: Not a verified hospital");
        _;
    }

    function registerUser(Role _role, string memory _metadataHash) external {
        require(users[msg.sender].role == Role.None, "User already registered");
        users[msg.sender] = User(_role, false, _metadataHash);
        emit UserRegistered(msg.sender, _role);
    }

    function verifyUser(address _user, bool _status) external onlyOwner {
        require(users[_user].role != Role.None, "User not registered");
        users[_user].isVerified = _status;
        if (_status) {
            emit UserVerified(_user);
        } else {
            emit UserUnverified(_user);
        }
    }
}
