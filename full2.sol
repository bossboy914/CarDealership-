
To modify the smart contract for purchasing real estate, we can adjust the struct and functions to fit the characteristics of real estate transactions. Below is the updated smart contract:

solidity
Copy code
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

    // Function to create a smart contract for purchasing the property
    function createPurchaseContract(string memory location, uint256 price) public payable onlyPropertyOwner(location) {
        require(!properties[location].isMortgaged, "Property is already mortgaged.");
        require(!properties[location].isRented, "Property is already rented.");
        require(properties[location].price == 0, "Purchase contract already created.");

        properties[location].price = price;

        emit PropertyPurchased(location, msg.sender, price);
    }

    // Function to create a smart contract for renting the property
    function createRentContract(string memory location, uint256 monthlyRent) public onlyPropertyOwner(location) {
        require(!properties[location].isMortgaged, "Property is already mortgaged.");
        require(!properties[location].isRented, "Property is already rented.");

        properties[location].isRented = true;
        properties[location].price = monthlyRent;

        emit PropertyRented(location, msg.sender, monthlyRent);
        }

    // ... (other functions for additional features as per your requirements)

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

    // Function to calculate the adjusted price for used properties based on their area and condition
    function calculateAdjustedPrice(string memory location) private view returns (uint256) {
        // Add your pricing adjustment logic here based on the area and condition of the property
        // This is just a placeholder function to demonstrate the concept.
        uint256 basePrice = properties[location].price;
        uint256 adjustedPrice = basePrice * 90 / 100; // For example, apply a 10% discount for used properties
        return adjustedPrice;
    }
}