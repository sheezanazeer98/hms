// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title HealthcareManagementSystem
 * @dev A blockchain-based healthcare system for managing user data securely.
 */
contract HealthcareManagementSystem01 is Ownable {
    // Enum for user roles
    enum Role { None, Patient, Hospital }

    // Struct for storing user information
    struct User {
        Role role; // User role: Patient or Hospital
        bool isVerified;
        string metadataHash; // Metadata or health data stored as IPFS hash
    }

    // Struct for storing feedback information
    struct Feedback {
        address hospital;
        string feedbackText;
        uint256 timestamp;
    }

    // Mappings
    mapping(address => User) private users; // Maps user addresses to their data
    mapping(address => mapping(address => bool)) private approvedHospitals; // Patient to approved hospitals mapping
    mapping(address => Feedback[]) private feedbacks; // Patient to feedback array mapping

    // Events
    event UserRegistered(address indexed user, Role role);
    event UserVerified(address indexed user);
    event UserUnverified(address indexed user);
    event DataUpdated(address indexed user, string metadataHash);
    event HospitalApproved(address indexed patient, address indexed hospital);
    event HospitalDisapproved(address indexed patient, address indexed hospital);
    event FeedbackSubmitted(
        address indexed patient,
        address indexed hospital,
        string feedback
    );

    /**
     * @dev Modifier to check if the caller is a verified patient.
     */
    modifier onlyVerifiedPatient() {
        require(
            users[msg.sender].isVerified && users[msg.sender].role == Role.Patient,
            "Unauthorized: Patient not verified"
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller is a verified hospital.
     */
    modifier onlyVerifiedHospital() {
        require(
            users[msg.sender].isVerified && users[msg.sender].role == Role.Hospital,
            "Unauthorized: Hospital not verified"
        );
        _;
    }


    constructor() Ownable(msg.sender) {
        
    }
    /**
     * @dev Registers a user as a patient.
     */
    function registerPatient(string memory _metadataHash) external {
        require(users[msg.sender].role == Role.None, "User already registered");

        users[msg.sender] = User({
            role: Role.Patient,
            isVerified: false,
            metadataHash: _metadataHash
        });

        emit UserRegistered(msg.sender, Role.Patient);
    }

    /**
     * @dev Registers a user as a hospital.
     */
    function registerHospital(string memory _metadataHash) external {
        require(users[msg.sender].role == Role.None, "User already registered");

        users[msg.sender] = User({
            role: Role.Hospital,
            isVerified: false,
            metadataHash: _metadataHash
        });

        emit UserRegistered(msg.sender, Role.Hospital);
    }

    /**
     * @dev Admin verifies a user.
     */
    function verifyUser(address _user) external onlyOwner {
        require(users[_user].role != Role.None, "User not registered");
        require(!users[_user].isVerified, "User already verified");

        users[_user].isVerified = true;
        emit UserVerified(_user);
    }

    /**
     * @dev Admin unverifies a user.
     */
    function unverifyUser(address _user) external onlyOwner {
        require(users[_user].isVerified, "User not verified");

        users[_user].isVerified = false;
        emit UserUnverified(_user);
    }

    /**
     * @dev Updates user data.
     */
    function updateData(string memory _metadataHash) external {
        require(users[msg.sender].isVerified, "User not verified");

        users[msg.sender].metadataHash = _metadataHash;
        emit DataUpdated(msg.sender, _metadataHash);
    }

    /**
     * @dev Patients approve hospitals to access their data.
     */
    function approveHospital(address _hospital) external onlyVerifiedPatient {
        require(
            users[_hospital].role == Role.Hospital && users[_hospital].isVerified,
            "Hospital not verified"
        );

        approvedHospitals[msg.sender][_hospital] = true;
        emit HospitalApproved(msg.sender, _hospital);
    }

    /**
     * @dev Patients disapprove hospitals from accessing their data.
     */
    function disapproveHospital(address _hospital) external onlyVerifiedPatient {
        require(
            approvedHospitals[msg.sender][_hospital],
            "Hospital not approved"
        );

        approvedHospitals[msg.sender][_hospital] = false;
        emit HospitalDisapproved(msg.sender, _hospital);
    }

    /**
     * @dev Hospitals submit feedback on patient data.
     */
    function submitFeedback(address _patient, string memory _feedback)
        external
        onlyVerifiedHospital
    {
        require(
            approvedHospitals[_patient][msg.sender],
            "Access denied: Not approved"
        );

        feedbacks[_patient].push(
            Feedback({
                hospital: msg.sender,
                feedbackText: _feedback,
                timestamp: block.timestamp
            })
        );

        emit FeedbackSubmitted(_patient, msg.sender, _feedback);
    }

    /**
     * @dev Fetch patient data including feedbacks.
     */
    function getPatientData(address _patient)
        external
        view
        returns (string memory, Feedback[] memory)
    {
        require(
            msg.sender == _patient || approvedHospitals[_patient][msg.sender],
            "Access denied"
        );

        return (users[_patient].metadataHash, feedbacks[_patient]);
    }
}