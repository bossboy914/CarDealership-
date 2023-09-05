// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    struct Property {
        address owner;
        uint256 price;
        string location;
        string description;
        uint256 area; // Property area in square meters
        bool isMortgaged;
        bool isRented;
        string legalDocuments;
        address[] ownershipHistory; // Records of previous owners and transfers of ownership
        bool isInspected; // Additional feature: Property Inspection
        bool isViewed; // Additional feature: Property Viewing
        bool isUsed; // Flag to indicate if the property is used or new
    }

    // Mapping to store property information
    mapping(string => Property) public properties;

    // Other variables to ensure data security and privacy
    mapping(address => bool) private authorizedAccess; // List of authorized addresses that can access property data

    // Event to log property ownership transfer
    event PropertyOwnershipTransferred(string location, address indexed from, address indexed to);
    event PropertyMortgaged(string location, address indexed mortgagee, uint256 amount);
    event PropertyRented(string location, address indexed tenant, uint256 monthlyRent);
    event PropertyPurchased(string location, address indexed buyer, uint256 price);

    // Modifier to check if the caller is the property owner
    modifier onlyPropertyOwner(string memory location) {
        require(properties[location].owner == msg.sender, "You are not the property owner.");
        _;
    }

    // Modifier to check if the caller is an authorized address
    modifier onlyAuthorized() {
        require(authorizedAccess[msg.sender], "Unauthorized access.");
        _;
    }

    // Constructor to set up the smart contract
    constructor() {
        // Initialize any necessary variables here
    }

    // Function to register a new property on the blockchain platform
    function registerProperty(
        string memory location,
        uint256 price,
        string memory description,
        uint256 area,
        bool isUsed, // New field to specify if the property is used or new
        string memory legalDocuments // New field to store legal documents related to the property
    ) public onlyAuthorized {
        require(properties[location].owner == address(0), "Property with this location already exists.");

        properties[location] = Property({
            owner: msg.sender,
            price: price,
            location: location,
            description: description,
            area: area,
            isMortgaged: false,
            isRented: false,
            legalDocuments: legalDocuments,
            ownershipHistory: new address[](0),
            isInspected: false,
            isViewed: false,
            isUsed: isUsed, // Set the flag to indicate if the property is used or new
        });
    }

    // Function to add property inspection details
    function addInspectionDetails(string memory location, bool isInspected) public onlyPropertyOwner(location) {
        properties[location].isInspected = isInspected;
    }

    // Function to add property viewing details
    function addViewingDetails(string memory location, bool isViewed) public onlyPropertyOwner(location) {
        properties[location].isViewed = isViewed;
    }

    // Function to add property ownership transfer history
    function addOwnershipTransferHistory(string memory location, address newOwner) public onlyPropertyOwner(location) {
        properties[location].ownershipHistory.push(msg.sender);
        properties[location].owner = newOwner;

        emit PropertyOwnershipTransferred(location, msg.sender, newOwner);
    }

    // Function to add legal documents related to the property
    function addLegalDocuments(string memory location, string memory documents) public onlyPropertyOwner(location) {
        properties[location].legalDocuments = documents;
    }

    // Function to create a smart contract for purchasing, leasing, or mortgaging the property
    function createTransactionContract(string memory location, uint256 price) public payable onlyPropertyOwner(location) {
        require(properties[location].price == 0, "Transaction contract already created.");

        properties[location].price = price;

        if (properties[location].isRented) {
            emit PropertyRented(location, msg.sender, price);
        } else if (properties[location].isMortgaged) {
            emit PropertyMortgaged(location, msg.sender, price);
        } else {
            emit PropertyPurchased(location, msg.sender, price);
        }
    }

    // Function to retrieve property details and history (decryption is only allowed for authorized addresses)
    function getPropertyDetails(string memory location) public view onlyAuthorized returns (
        address owner,
        uint256 price,
        string memory description,
        uint256 area,
        bool isMortgaged,
        bool isRented,
        string memory legalDocuments,
        address[] memory ownershipHistory,
        bool isInspected,
        bool isViewed
    ) {
        Property memory property = properties[location];
        return (
            property.owner,
            property.price,
            property.description,
            property.area,
            property.isMortgaged,
            property.isRented,
            property.legalDocuments,
            property.ownershipHistory,
            property.isInspected,
            property.isViewed
        );
    }

    // Function to authorize access for specific addresses (e.g., real estate agents and regulators)
    function authorizeAccess(address authorizedAddress) public onlyPropertyOwner {
        authorizedAccess[authorizedAddress] = true;
    }

    // Function to revoke access for specific addresses (e.g., former agents or terminated contracts)
    function revokeAccess(address unauthorizedAddress) public onlyPropertyOwner {
        authorizedAccess[unauthorizedAddress] = false;
    }

    // Additional feature: Real-Time Property Inventory
    string[] public propertyInventory;

    // Function to add a property to the inventory
    function addToPropertyInventory(string memory location) public onlyAuthorized {
        propertyInventory.push(location);
    }

    // Function to remove a property from the inventory
    function removeFromPropertyInventory(string memory location) public onlyAuthorized {
        for (uint256 i = 0; i < propertyInventory.length; i++) {
            if (keccak256(bytes(propertyInventory[i])) == keccak256(bytes(location))) {
                propertyInventory[i] = propertyInventory[propertyInventory.length - 1];
                propertyInventory.pop();
                break;
            }
        }
    }

    // Function to get the current property inventory
    function getPropertyInventory() public view returns (string[] memory) {
        return propertyInventory;
    }

    // Additional feature: Financing and Interest Rates
    // Mapping to store financing details and interest rates for each property
    mapping(string => string) private financingDetails;

    // Function to add financing details and interest rates for a property
    function addFinancingDetails(string memory location, string memory details) public onlyAuthorized {
        financingDetails[location] = details;
    }

    // Function to get the financing details and interest rates for a property
    function getFinancingDetails(string memory location) public view returns (string memory) {
        return financingDetails[location];
    }

    // Additional feature: Local Regulations and Dispute Resolution
    string private localRegulations;

    // Function to set local regulations information
    function setLocalRegulations(string memory regulations) public onlyAuthorized {
        localRegulations = regulations;
    }

    // Function to get local regulations information
    function getLocalRegulations() public view returns (string memory) {
        return localRegulations;
    }

    // Additional feature: Third-Party Verification
    // Mapping to store the information of third-party verification providers for each property
    mapping(string => address[]) private verificationProviders;

    // Function to add a verification provider for a property
    function addVerificationProvider(string memory location, address provider) public onlyAuthorized {
        verificationProviders[location].push(provider);
    }

    // Function to get the verification providers for a property
    function getVerificationProviders(string memory location) public view returns (address[] memory) {
        return verificationProviders[location];
    }

    // ... (other existing functions from the original codes)
}
