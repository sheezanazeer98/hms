// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./UserManagement.sol";

contract AccessControl is UserManagement {
    mapping(address => mapping(address => bool)) internal approvedHospitals;

    event HospitalAccessUpdated(address indexed patient, address indexed hospital, bool status);

    function updateHospitalAccess(address _hospital, bool _status) external onlyVerifiedPatient {
        require(users[_hospital].role == Role.Hospital && users[_hospital].isVerified, "Hospital not verified");
        approvedHospitals[msg.sender][_hospital] = _status;
        emit HospitalAccessUpdated(msg.sender, _hospital, _status);
    }

    function hasAccess(address _patient, address _hospital) public view returns (bool) {
        return approvedHospitals[_patient][_hospital];
    }
}
