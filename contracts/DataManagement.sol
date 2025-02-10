// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./UserManagement.sol";
import "./SignatureVerifier.sol";

contract DataManagement is UserManagement, SignatureVerifier {
    event DataUpdated(address indexed user, string metadataHash);

    function updateData(
        string memory _metadataHash,
        bytes32 _ethSignedMessageHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external {
        require(users[msg.sender].isVerified, "User not verified");
        require(_verify(msg.sender, _ethSignedMessageHash, r, s, v), "Invalid signature");
        users[msg.sender].metadataHash = _metadataHash;
        emit DataUpdated(msg.sender, _metadataHash);
    }

    function getUserData(address _user) external view returns (string memory) {
        require(msg.sender == _user || users[msg.sender].role == Role.Hospital, "Access denied");
        return users[_user].metadataHash;
    }
}
