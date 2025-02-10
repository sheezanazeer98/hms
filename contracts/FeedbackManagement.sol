// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./AccessControl.sol";
import "./SignatureVerifier.sol";

contract FeedbackManagement is AccessControl, SignatureVerifier {
    struct Feedback {
        address hospital;
        string feedbackText;
        uint256 timestamp;
    }

    mapping(address => Feedback[]) private feedbacks;

    event FeedbackSubmitted(address indexed patient, address indexed hospital, string feedback);

    function submitFeedback(
        address _patient,
        string memory _feedback,
        bytes32 _ethSignedMessageHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external onlyVerifiedHospital {
        require(hasAccess(_patient, msg.sender), "Access denied");
        require(_verify(msg.sender, _ethSignedMessageHash, r, s, v), "Invalid signature");
        feedbacks[_patient].push(Feedback(msg.sender, _feedback, block.timestamp));
        emit FeedbackSubmitted(_patient, msg.sender, _feedback);
    }

    function getFeedback(address _patient) external view returns (Feedback[] memory) {
        require(msg.sender == _patient || hasAccess(_patient, msg.sender), "Access denied");
        return feedbacks[_patient];
    }
}
