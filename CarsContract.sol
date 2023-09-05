// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CarDealership {
    struct Car {
        string VIN;
        string make;
        string model;
        uint256 year;
        string color;
        string engineSpecifications;
        bool isCustomized;
        address owner;
        bool isLeased;
        bool isFinanced;
        uint256 leaseDuration; // Lease duration in months
        uint256 monthlyLeasePayment; // Monthly lease payment in wei
        uint256 purchasePrice; // Purchase price in wei
        address financier; // Address of the financing institution
        string registrationDocuments; // Digital copy of registration documents
        string maintenanceHistory; // Records of maintenance and service history
        address[] ownershipHistory; // Records of previous owners and transfers of ownership
        bool isInspected; // Additional feature: Vehicle Inspection
        bool isTestDriven; // Additional feature: Test Drive
        uint256 mileage; // Mileage of the car
        string condition; // Condition of the car ("1," "2," "3," "4," "5," "6," "7," "8," "9," "10,")
        string vehicleHistory; // Records of accidents, repairs, and ownership changes
        bool isInspected; // Whether the car is inspected
        bool isTestDriven; // Whether the car is test-driven
        bool isUsed; // Flag to indicate if the car is used or new
    }

    // Mapping to store car information
    mapping(string => Car) public cars;

    // Other variables to ensure data security and privacy
    mapping(address => bool) private authorizedAccess; // List of authorized addresses that can access vehicle data
    mapping(string => bytes32) private encryptedData; // Encrypted data storage on the blockchain
    bytes32 private encryptionKey; // Encryption key to protect sensitive data

    // Event to log car ownership transfer
    event CarOwnershipTransferred(string VIN, address indexed from, address indexed to);
    event CarFinanced(string VIN, address indexed financier, uint256 amount);
    event CarLeased(string VIN, address indexed buyer, uint256 leaseDuration, uint256 monthlyLeasePayment);
    event CarPurchased(string VIN, address indexed buyer, uint256 purchasePrice);

    // Modifier to check if the caller is the car owner
    modifier onlyCarOwner(string memory VIN) {
        require(cars[VIN].owner == msg.sender, "You are not the car owner.");
        _;
    }

    // Modifier to check if the caller is an authorized address
    modifier onlyAuthorized() {
        require(authorizedAccess[msg.sender], "Unauthorized access.");
        _;
    }

    // Constructor to set the encryption key
    constructor(bytes32 _encryptionKey) {
        encryptionKey = _encryptionKey;
    }

    // Function to register a new car on the blockchain platform
    function registerCar(
        string memory VIN,
        string memory make,
        string memory model,
        uint256 year,
        string memory color,
        string memory engineSpecifications
        bool isUsed, // New field to specify if the car is used or new
        uint256 mileage, // New field to specify the mileage of the car
        string memory condition // New field to specify the condition of the car
    ) public onlyAuthorized {
        require(bytes(VIN).length == 17, "Invalid VIN length.");
        require(cars[VIN].owner == address(0), "Car with VIN already exists.");

        cars[VIN] = Car({
            VIN: VIN,
            make: make,
            model: model,
            year: year,
            color: color,
            engineSpecifications: engineSpecifications,
            isCustomized: false,
            owner: msg.sender,
            isLeased: false,
            isFinanced: false,
            leaseDuration: 0,
            monthlyLeasePayment: 0,
            purchasePrice: 0,
            financier: address(0),
            registrationDocuments: "",
            maintenanceHistory: "",
            ownershipHistory: new address[](0),
            isInspected: false,
            isTestDriven: false
                  isUsed: isUsed, // Set the flag to indicate if the car is used or new
            mileage: mileage, // Set the mileage of the car
            condition: condition, // Set the condition of the car
            vehicleHistory: "" // Initialize vehicleHistory as empty
        });
    }

    // Function to add vehicle history for a car
    function addVehicleHistory(string memory VIN, string memory history) public onlyCarOwner(VIN) {
        require(cars[VIN].isUsed, "Vehicle history can only be added for used cars.");
        cars[VIN].vehicleHistory = history;
    }

    // Function to get vehicle history for a car
    function getVehicleHistory(string memory VIN) public view returns (string memory) {
        require(cars[VIN].isUsed, "Vehicle history is available only for used cars.");
        return cars[VIN].vehicleHistory;
    }

    // Function to create a smart contract for the car purchase (used cars may have different pricing considerations)
    function createPurchaseContract(string memory VIN, uint256 purchasePrice) public payable onlyCarOwner(VIN) {
        require(!cars[VIN].isLeased, "Car is already leased.");
        require(!cars[VIN].isFinanced, "Car is already financed.");
        require(cars[VIN].purchasePrice == 0, "Purchase contract already created.");

        if (cars[VIN].isUsed) {
            // Add pricing adjustment for used cars based on mileage, condition, etc.
            require(purchasePrice >= calculateAdjustedPrice(VIN), "Invalid purchase price for the used car.");
        }

        cars[VIN].purchasePrice = purchasePrice;

        emit CarPurchased(VIN, msg.sender, purchasePrice);

        // Encrypt and store purchase data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, cars[VIN].purchasePrice));
    }

    // Function to customize a car with optional features, colors, or accessories
    function customizeCar(string memory VIN) public onlyCarOwner(VIN) {
        require(!cars[VIN].isCustomized, "Car is already customized.");
        // Add customization logic here

        cars[VIN].isCustomized = true;

        // Encrypt and store custom data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, cars[VIN].make, cars[VIN].model, cars[VIN].year));
    }

    // Function to create a smart contract for the car purchase
    function createPurchaseContract(string memory VIN, uint256 purchasePrice) public payable onlyCarOwner(VIN) {
        require(!cars[VIN].isLeased, "Car is already leased.");
        require(!cars[VIN].isFinanced, "Car is already financed.");
        require(cars[VIN].purchasePrice == 0, "Purchase contract already created.");

        cars[VIN].purchasePrice = purchasePrice;

        emit CarPurchased(VIN, msg.sender, purchasePrice);

        // Encrypt and store purchase data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, cars[VIN].purchasePrice));
    }

    // Function to create a smart contract for leasing a car
    function createLeaseContract(string memory VIN, uint256 leaseDuration, uint256 monthlyLeasePayment) public onlyCarOwner(VIN) {
        require(!cars[VIN].isLeased, "Car is already leased.");
        require(!cars[VIN].isFinanced, "Car is already financed.");
        require(cars[VIN].leaseDuration == 0, "Lease contract already created.");

        cars[VIN].isLeased = true;
        cars[VIN].leaseDuration = leaseDuration;
        cars[VIN].monthlyLeasePayment = monthlyLeasePayment;

        emit CarLeased(VIN, msg.sender, leaseDuration, monthlyLeasePayment);

        // Encrypt and store lease data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, cars[VIN].leaseDuration, cars[VIN].monthlyLeasePayment));
    }

    // Function to create a smart contract for financing a car
    function createFinanceContract(string memory VIN, address financier, uint256 financingAmount) public onlyCarOwner(VIN) {
        require(!cars[VIN].isLeased, "Car is already leased.");
        require(!cars[VIN].isFinanced, "Car is already financed.");
        require(cars[VIN].financier == address(0), "Finance contract already created.");

        cars[VIN].isFinanced = true;
        cars[VIN].financier = financier;

        emit CarFinanced(VIN, financier, financingAmount);

        // Encrypt and store financing data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, financier, financingAmount));
    }

    // Function to transfer car ownership to another address
    function transferCarOwnership(string memory VIN, address newOwner) public onlyCarOwner(VIN) {
        cars[VIN].ownershipHistory.push(msg.sender);
        cars[VIN].owner = newOwner;

        emit CarOwnershipTransferred(VIN, msg.sender, newOwner);

        // Encrypt and store transfer data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, newOwner));
    }

    // Function to add registration documents to a car
    function addRegistrationDocuments(string memory VIN, string memory documents) public onlyCarOwner(VIN) {
        cars[VIN].registrationDocuments = documents;
    }

    // Function to add maintenance history to a car
    function addMaintenanceHistory(string memory VIN, string memory history) public onlyCarOwner(VIN) {
        cars[VIN].maintenanceHistory = history;
    }

    // Function to mark the car as inspected
    function markCarInspected(string memory VIN) public onlyCarOwner(VIN) {
        cars[VIN].isInspected = true;
    }

    // Function to mark the car as test-driven
    function markCarTestDriven(string memory VIN) public onlyCarOwner(VIN) {
        cars[VIN].isTestDriven = true;
    }

    // Function to retrieve car details and history (decryption is only allowed for authorized addresses)
    function getCarDetails(string memory VIN) public view onlyAuthorized returns (
        string memory make,
        string memory model,
        uint256 year,
        string memory color,
        string memory engineSpecifications,
        bool isCustomized,
        address owner,
        bool isLeased,
        bool isFinanced,
        uint256 leaseDuration,
        uint256 monthlyLeasePayment,
        uint256 purchasePrice,
        address financier,
        string memory registrationDocuments,
        string memory maintenanceHistory,
        address[] memory ownershipHistory,
        bool isInspected,
        bool isTestDriven
    ) {
        Car memory car = cars[VIN];
        return (
            car.make,
            car.model,
            car.year,
            car.color,
            car.engineSpecifications,
            car.isCustomized,
            car.owner,
            car.isLeased,
            car.isFinanced,
            car.leaseDuration,
            car.monthlyLeasePayment,
            car.purchasePrice,
            car.financier,
            car.registrationDocuments,
            car.maintenanceHistory,
            car.ownershipHistory,
            car.isInspected,
            car.isTestDriven
        );
    }

    // Function to authorize access for specific addresses (e.g., dealership staff and regulators)
    function authorizeAccess(address authorizedAddress) public onlyCarOwner(authorizedAddress) {
        authorizedAccess[authorizedAddress] = true;
    }

    // Function to revoke access for specific addresses (e.g., former staff or terminated contracts)
    function revokeAccess(address unauthorizedAddress) public onlyCarOwner(unauthorizedAddress) {
        authorizedAccess[unauthorizedAddress] = false;
    }

    // Function to change the encryption key (only the dealership can update the encryption key)
    function updateEncryptionKey(bytes32 newEncryptionKey) public onlyCarOwner(dealershipAddress) {
        encryptionKey = newEncryptionKey;
    }

    // Additional feature: Vehicle Identification Number (VIN) Verification
    // Function to verify the VIN externally
    function verifyVIN(string memory VIN) public view returns (bool) {
        // Call an external service to verify the VIN
        // Return true if the VIN is valid, false otherwise
    }

    // Additional feature: Warranty and After-Sales Service
    // Mapping to store warranty details and after-sales service agreements
    mapping(string => string) private warrantyDocuments;

    // Function to add warranty details or after-sales service agreements
    function addWarrantyDocuments(string memory VIN, string memory documentLink) public onlyAuthorized {
        warrantyDocuments[VIN] = documentLink;
    }

    // Function to get the warranty details or after-sales service agreements for a car
    function getWarrantyDocuments(string memory VIN) public view returns (string memory) {
        return warrantyDocuments[VIN];
    }

    // Additional feature: Insurance
    // Mapping to store insurance status for each car
    mapping(string => bool) private hasInsurance;

    // Function to mark that the car has valid insurance
    function markInsurance(string memory VIN) public onlyCarOwner(VIN) {
        hasInsurance[VIN] = true;
    }

    // Function to check if the car has valid insurance
    function hasValidInsurance(string memory VIN) public view returns (bool) {
        return hasInsurance[VIN];
    }

    // Additional feature: Financing and Interest Rates
    // Mapping to store financing details and interest rates
    mapping(string => string) private financingDetails;

    // Function to add financing details and interest rates for a car
    function addFinancingDetails(string memory VIN, string memory documentLink) public onlyAuthorized {
        financingDetails[VIN] = documentLink;
    }

    // Function to get the financing details and interest rates for a car
    function getFinancingDetails(string memory VIN) public view returns (string memory) {
        return financingDetails[VIN];
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
    // Mapping to store the information of third-party verification providers
    mapping(string => address[]) private verificationProviders;

    // Function to add a verification provider for a car
    function addVerificationProvider(string memory VIN, address provider) public onlyAuthorized {
        verificationProviders[VIN].push(provider);
    }

    // Function to get the verification providers for a car
    function getVerificationProviders(string memory VIN) public view returns (address[] memory) {
        return verificationProviders[VIN];
    }

    // Additional feature: Ownership Transfer History
    mapping(string => address[]) private ownershipTransferHistory;

    // Function to get ownership transfer history for a car
    function getOwnershipTransferHistory(string memory VIN) public view returns (address[] memory) {
        return ownershipTransferHistory[VIN];
    }

    // Additional feature: Vehicle Service Records
    mapping(string => string[]) private serviceRecords;

    // Function to add service record for a car
    function addServiceRecord(string memory VIN, string memory record) public onlyCarOwner(VIN) {
        serviceRecords[VIN].push(record);
    }

    // Function to get service records for a car
    function getServiceRecords(string memory VIN) public view returns (string[] memory) {
        return serviceRecords[VIN];
    }

    // Additional feature: Extended Warranty Options
    mapping(string => string) private extendedWarrantyOptions;

    // Function to add extended warranty option for a car
    function addExtendedWarrantyOption(string memory VIN, string memory warrantyDetails) public onlyAuthorized {
        extendedWarrantyOptions[VIN] = warrantyDetails;
    }

    // Function to get extended warranty option for a car
    function getExtendedWarrantyOption(string memory VIN) public view returns (string memory) {
        return extendedWarrantyOptions[VIN];
    }

    // Additional feature: Vehicle Inspection Reports
    mapping(string => string) private inspectionReports;

    // Function to add inspection report for a car
    function addInspectionReport(string memory VIN, string memory report) public onlyAuthorized {
        inspectionReports[VIN] = report;
    }

    // Function to get inspection report for a car
    function getInspectionReport(string memory VIN) public view returns (string memory) {
        return inspectionReports[VIN];
    }

    // Additional feature: Additional Payment Options
    // Assuming that the contract supports multiple currencies including Ether (ETH) and an ERC20 token "CarCoin"
    // For simplicity, this implementation only allows ETH payments
    uint256 public constant carPriceInCarCoin = 1000; // Price of the car in CarCoin
    uint256 public constant exchangeRate = 10; // Conversion rate of 1 CarCoin to 10 ETH

    // Function to purchase a car using CarCoin
    function purchaseCarWithCarCoin(string memory VIN, uint256 carCoinAmount) public payable onlyCarOwner(VIN) {
        require(!cars[VIN].isLeased && !cars[VIN].isFinanced, "Car is already leased or financed.");
        require(cars[VIN].purchasePrice == 0, "Purchase contract already created.");
        require(carCoinAmount >= carPriceInCarCoin, "Insufficient CarCoin balance.");

        uint256 ethAmount = carCoinAmount / exchangeRate;
        require(msg.value >= ethAmount, "Insufficient ETH payment.");

        cars[VIN].purchasePrice = ethAmount;

        emit CarPurchased(VIN, msg.sender, ethAmount);

        // Encrypt and store purchase data
        encryptedData[VIN] = keccak256(abi.encodePacked(VIN, msg.sender, cars[VIN].purchasePrice));
    }

    // ... (other existing functions from the original code)

    // Additional feature: Real-Time Car Inventory
    string[] public carInventory;

    // Function to add a car to the inventory
    function addToCarInventory(string memory VIN) public onlyAuthorized {
        carInventory.push(VIN);
    }

    // Function to remove a car from the inventory
    function removeFromCarInventory(string memory VIN) public onlyAuthorized {
        for (uint256 i = 0; i < carInventory.length; i++) {
            if (keccak256(bytes(carInventory[i])) == keccak256(bytes(VIN))) {
                carInventory[i] = carInventory[carInventory.length - 1];
                carInventory.pop();
                break;
            }
        }
    }

    // Function to get the current car inventory
    function getCarInventory() public view returns (string[] memory) {
        return carInventory;
    }
    
    // Function to calculate the adjusted price for used cars based on mileage, condition, etc.
    function calculateAdjustedPrice(string memory VIN) private view returns (uint256) {
        // Add your pricing adjustment logic here based on mileage, condition, etc.
        // This is just a placeholder function to demonstrate the concept.
        uint256 basePrice = cars[VIN].purchasePrice;
        uint256 adjustedPrice = basePrice * 90 / 100; // For example, apply a 10% discount for used cars
        return adjustedPrice;
    }
}
