// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PostSevaComplaints {
    // Enum for complaint status
    enum Status { Review, Accepted, Open, InProgress, Closed, Rejected }

    // Struct to store a complaint
    struct Complaint {
        uint id;
        string citizen;
        string description;
        Status status;
        string staffName;
        string postOfficeCode;
        uint timestamp;
        string feedbackAuthor;
        string feedback;
    }

    // Events
    event ComplaintFiled(uint complaintId, string citizen, string description, string postOfficeCode);
    event ComplaintUpdated(uint complaintId, Status status);
    event StaffAssigned(uint complaintId, string staffName);
    event FeedbackAdded(uint complaintId, string feedbackAuthor, string feedback);

    // Variables
    uint private complaintCounter = 0;
    mapping(uint => Complaint) private complaints; // Complaints by ID
    address public postOfficeAdmin;

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == postOfficeAdmin, "Only the admin can perform this action");
        _;
    }

    modifier validComplaint(uint complaintId) {
        require(complaints[complaintId].timestamp != 0, "Complaint does not exist");
        _;
    }

    // Constructor to set the admin
    constructor() {
        postOfficeAdmin = msg.sender;
    }

    // Function to file a complaint
    function fileComplaint(string memory _citizen, string memory _description, string memory _postOfficeCode) public {
        require(bytes(_citizen).length > 0, "Citizen cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(bytes(_postOfficeCode).length > 0, "Post office code cannot be empty");

        complaintCounter++;
        complaints[complaintCounter] = Complaint({
            id: complaintCounter,
            citizen: _citizen,
            description: _description,
            status: Status.InProgress,
            staffName: "", // No staff assigned initially
            postOfficeCode: _postOfficeCode,
            timestamp: block.timestamp,
            feedbackAuthor: "",
            feedback: ""
        });

        emit ComplaintFiled(complaintCounter, _citizen, _description, _postOfficeCode);
    }

    // Function to assign a staff member by name
    function assignStaff(uint _complaintId, string memory _staffName) public onlyAdmin validComplaint(_complaintId) {
        require(bytes(_staffName).length > 0, "Staff name cannot be empty");

        complaints[_complaintId].staffName = _staffName;

        emit StaffAssigned(_complaintId, _staffName);
    }

    // Function to update the status of a complaint
    function updateComplaintStatus(uint _complaintId, Status _status) public onlyAdmin validComplaint(_complaintId) {
        complaints[_complaintId].status = _status;

        emit ComplaintUpdated(_complaintId, _status);
    }

    // Function to add feedback to a complaint
    function addFeedback(uint _complaintId, string memory _feedbackAuthor, string memory _feedback) public validComplaint(_complaintId) {
        require(bytes(_feedbackAuthor).length > 0, "Feedback author cannot be empty");
        require(bytes(_feedback).length > 0, "Feedback cannot be empty");

        complaints[_complaintId].feedbackAuthor = _feedbackAuthor;
        complaints[_complaintId].feedback = _feedback;

        emit FeedbackAdded(_complaintId, _feedbackAuthor, _feedback);
    }

    // Function to fetch a specific complaint
    function getComplaint(uint _complaintId) public view validComplaint(_complaintId) returns (
        uint id,
        string memory citizen,
        string memory description,
        Status status,
        string memory staffName,
        string memory postOfficeCode,
        uint timestamp,
        string memory feedbackAuthor,
        string memory feedback
    ) {
        Complaint memory complaint = complaints[_complaintId];
        return (
            complaint.id,
            complaint.citizen,
            complaint.description,
            complaint.status,
            complaint.staffName,
            complaint.postOfficeCode,
            complaint.timestamp,
            complaint.feedbackAuthor,
            complaint.feedback
        );
    }

    // Function to fetch all complaints
    function getAllComplaints() public view returns (Complaint[] memory) {
        Complaint[] memory allComplaints = new Complaint[](complaintCounter);

        for (uint i = 1; i <= complaintCounter; i++) {
            allComplaints[i - 1] = complaints[i];
        }

        return allComplaints;
    }

    // Function to fetch total complaints count
    function getComplaintCount() public view returns (uint) {
        return complaintCounter;
    }
}

// Contract deployment address: 0x5F8F608F7F30EC59b54c32D28E5AB00d372B1DE6