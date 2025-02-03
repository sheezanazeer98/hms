// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title HealthcareManagementSystem
 * @dev A blockchain-based healthcare management system for patient and hospital interactions.
 * This contract allows registration, verification, data updates, and feedback submission.
 */
contract HealthcareManagementSystem is Ownable {
    // Enum representing user roles
    enum Role { None, Patient, Hospital }

    // Struct representing user details
    struct User {
        Role role; // Role of the user
        bool isVerified; // Verification status
        string metadataHash; // IPFS hash storing metadata of the user
    }

    // Struct representing feedback from hospitals
    struct Feedback {
        address hospital; // Address of the hospital providing feedback
        string feedbackText; // Feedback content
        uint256 timestamp; // Timestamp of feedback submission
    }

    // Mappings to store user data and permissions
    mapping(address => User) private users; // Maps user addresses to user details
    mapping(address => mapping(address => bool)) private approvedHospitals; // Maps patient to approved hospitals
    mapping(address => Feedback[]) private feedbacks; // Stores feedback given to patients

    // Events for tracking key actions
    event UserRegistered(address indexed user, Role role);
    event UserVerified(address indexed user);
    event UserUnverified(address indexed user);
    event DataUpdated(address indexed user, string metadataHash);
    event HospitalApproved(address indexed patient, address indexed hospital);
    event HospitalDisapproved(address indexed patient, address indexed hospital);
    event FeedbackSubmitted(address indexed patient, address indexed hospital, string feedback);

    /**
     * @dev Constructor to initialize contract with the deployer as the owner.
     */
    constructor() Ownable(msg.sender) {}

    /**
     * @dev Modifier to allow only verified patients.
     */
    modifier onlyVerifiedPatient() {
        require(users[msg.sender].isVerified && users[msg.sender].role == Role.Patient, "Unauthorized: Not a verified patient");
        _;
    }

    /**
     * @dev Modifier to allow only verified hospitals.
     */
    modifier onlyVerifiedHospital() {
        require(users[msg.sender].isVerified && users[msg.sender].role == Role.Hospital, "Unauthorized: Not a verified hospital");
        _;
    }

    /**
     * @dev Allows a user to register as a patient.
     * @param _metadataHash IPFS hash storing user metadata.
     */
    function registerPatient(string memory _metadataHash) external {
        require(users[msg.sender].role == Role.None, "User already registered");
        users[msg.sender] = User(Role.Patient, false, _metadataHash);
        emit UserRegistered(msg.sender, Role.Patient);
    }

    /**
     * @dev Allows a user to register as a hospital.
     * @param _metadataHash IPFS hash storing hospital metadata.
     */
    function registerHospital(string memory _metadataHash) external {
        require(users[msg.sender].role == Role.None, "User already registered");
        users[msg.sender] = User(Role.Hospital, false, _metadataHash);
        emit UserRegistered(msg.sender, Role.Hospital);
    }

    /**
     * @dev Allows the contract owner to verify a registered user.
     * @param _user Address of the user to verify.
     */
    function verifyUser(address _user) external onlyOwner {
        require(users[_user].role != Role.None, "User not registered");
        require(!users[_user].isVerified, "User already verified");
        users[_user].isVerified = true;
        emit UserVerified(_user);
    }

    /**
     * @dev Allows the contract owner to unverify a user.
     * @param _user Address of the user to unverify.
     */
    function unverifyUser(address _user) external onlyOwner {
        require(users[_user].isVerified, "User not verified");
        users[_user].isVerified = false;
        emit UserUnverified(_user);
    }

    /**
     * @dev Updates user metadata with signature verification.
     * @param _metadataHash New IPFS hash storing updated metadata.
     * @param _ethSignedMessageHash Signed message hash.
     * @param r Signature component.
     * @param s Signature component.
     * @param v Signature recovery ID.
     */
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

    /**
     * @dev Approves a hospital for accessing a patient's data.
     * @param _hospital Address of the hospital to approve.
     */
    function approveHospital(address _hospital) external onlyVerifiedPatient {
        require(users[_hospital].role == Role.Hospital && users[_hospital].isVerified, "Hospital not verified");
        approvedHospitals[msg.sender][_hospital] = true;
        emit HospitalApproved(msg.sender, _hospital);
    }

    /**
     * @dev Disapproves a previously approved hospital.
     * @param _hospital Address of the hospital to disapprove.
     */
    function disapproveHospital(address _hospital) external onlyVerifiedPatient {
        require(approvedHospitals[msg.sender][_hospital], "Hospital not approved");
        approvedHospitals[msg.sender][_hospital] = false;
        emit HospitalDisapproved(msg.sender, _hospital);
    }

    /**
     * @dev Allows verified hospitals to submit feedback for patients.
     */
    function submitFeedback(
        address _patient,
        string memory _feedback,
        bytes32 _ethSignedMessageHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) external onlyVerifiedHospital {
        require(approvedHospitals[_patient][msg.sender], "Access denied");
        require(_verify(msg.sender, _ethSignedMessageHash, r, s, v), "Invalid signature");
        feedbacks[_patient].push(Feedback(msg.sender, _feedback, block.timestamp));
        emit FeedbackSubmitted(_patient, msg.sender, _feedback);
    }

    /**
     * @dev Retrieves metadata and feedbacks for a patient.
     */
    function getPatientData(address _patient) external view returns (string memory, Feedback[] memory) {
        require(msg.sender == _patient || approvedHospitals[_patient][msg.sender], "Access denied");
        return (users[_patient].metadataHash, feedbacks[_patient]);
    }

    /**
     * @dev Verifies the signature of a signed message.
     */
    function _verify(
        address _signer,
        bytes32 _ethSignedMessageHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal pure returns (bool) {
        return ecrecover(_ethSignedMessageHash, v, r, s) == _signer;
    }
}
