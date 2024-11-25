// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PostSevaComplaints {
    // Enum for complaint status
    enum Status { Pending, InProgress, Resolved, Rejected }

    // Struct to store a complaint
    struct Complaint {
        uint id;
        address citizen;
        string description;
        Status status;
        string staffName; // Staff handling the complaint
        string postOfficeCode; // Code of the post office
        uint timestamp;
    }

    // Events
    event ComplaintFiled(uint complaintId, address indexed citizen, string description, string postOfficeCode);
    event ComplaintUpdated(uint complaintId, Status status);
    event StaffAssigned(uint complaintId, string staffName);

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
    function fileComplaint(string memory _description, string memory _postOfficeCode) public {
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(bytes(_postOfficeCode).length > 0, "Post office code cannot be empty");

        complaintCounter++;
        complaints[complaintCounter] = Complaint({
            id: complaintCounter,
            citizen: msg.sender,
            description: _description,
            status: Status.Pending,
            staffName: "", // No staff assigned initially
            postOfficeCode: _postOfficeCode,
            timestamp: block.timestamp
        });

        emit ComplaintFiled(complaintCounter, msg.sender, _description, _postOfficeCode);
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

    // Function to fetch a specific complaint
    function getComplaint(uint _complaintId) public view validComplaint(_complaintId) returns (
        uint id,
        address citizen,
        string memory description,
        Status status,
        string memory staffName,
        string memory postOfficeCode,
        uint timestamp
    ) {
        Complaint memory complaint = complaints[_complaintId];
        return (
            complaint.id,
            complaint.citizen,
            complaint.description,
            complaint.status,
            complaint.staffName,
            complaint.postOfficeCode,
            complaint.timestamp
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


// Contract Address: 0xaF37d6525BA4E37b4852e5B69C9CddA527219967