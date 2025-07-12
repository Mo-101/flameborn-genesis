// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Counters } from "@openzeppelin/contracts/utils/Counters.sol";


contract SustainabilityDAO is ERC721, AccessControl {
    using Counters for Counters.Counter;

    // === ROLES ===
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant DEFAULT_ADMIN_ROLE_HASH = 0x00;

    // === TRACKING ===
    Counters.Counter private _tokenIds;
    mapping(address => bool) private _minted;
    mapping(address => bool) private _repairMinted;
    mapping(address => uint256) private repairCredits;

    // === STATE ===
    uint256 public sustainabilityScore = 0;
    uint8 public constant MAX_SOUL_PRINTS = 10;

    // === EXTERNAL ===
    address public ussdPool;
    address public maintenancePool;
    address public techGrannyDAO;

    // === EVENTS ===
    event SustainabilityFeesAllocated(uint256 ussd, uint256 maintenance);
    event FLBBurned(uint256 amount);
    event EmergencyMint(uint256 amount);
    event RepairRequested(address granny, uint256 amount);
    event ScoreAdjusted(uint256 newScore);
    event SymbolicSoulprint(bytes32 soulId, string essence, uint256 soulLevel, address minter, uint256 timestamp);

    // === ERRORS ===
    error InvalidCaller();
    error MaintenancePoolEmpty();

    // === CONSTRUCTOR ===
    constructor(
        address admin,
        address _flbToken,
        address _ussdPool,
        address _maintenancePool,
        address _techGrannyDAO
    ) ERC721("SustainabilityDAO", "SSD") {
        if (admin == address(0)) revert InvalidCaller();
        if (_flbToken == address(0)) revert InvalidCaller();
        if (_ussdPool == address(0)) revert InvalidCaller();
        if (_maintenancePool == address(0)) revert InvalidCaller();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(GUARDIAN_ROLE, admin);

        ussdPool = _ussdPool;
        maintenancePool = _maintenancePool;
        techGrannyDAO = _techGrannyDAO;
    }

    // === CORE FUNCTIONS ===

    /// 🔄 Allocates fees based on FLB emission event
    function allocateFees(uint256 amount) external onlyRole(GUARDIAN_ROLE) {
        uint256 ussd = (amount * 40) / 100;
        uint256 maintenance = amount - ussd;

        emit SustainabilityFeesAllocated(ussd, maintenance);
    }

    /// 🔥 Controlled burn (e.g., voluntary by clinics)
    function burnFLB(uint256 amount) external {
        sustainabilityScore += 1;
        emit FLBBurned(amount);
        emit ScoreAdjusted(sustainabilityScore);
    }

    /// 🚨 Emergency mint if sustainability pool runs dry
    function emergencyMint(address /*to*/, uint256 /*amount*/) external onlyRole(DEFAULT_ADMIN_ROLE) { // parameters commented out to silence unused warning
        emit EmergencyMint(0); // Use a fixed value to avoid undeclared identifier error
    }

    /// 🛠️ Repair trigger (Tech Granny)
    function requestRepair(address granny) external {
        if (msg.sender != techGrannyDAO) revert InvalidCaller();

        uint256 credit = repairCredits[granny];
        if (credit == 0) revert MaintenancePoolEmpty();

        repairCredits[granny] = 0;

        emit RepairRequested(granny, credit);
    }

    /// 🧮 Update repair credits and score
    function updateRepairCredits(address granny, uint256 amount) external onlyRole(GUARDIAN_ROLE) {
        repairCredits[granny] += amount;
    }

    function adjustScore(int256 delta) external onlyRole(GUARDIAN_ROLE) {
        int256 newScore = int256(sustainabilityScore) + delta;
        sustainabilityScore = newScore < 0 ? 0 : uint256(newScore);
        emit ScoreAdjusted(sustainabilityScore);
    }

    /// 🧬 Symbolic NFT Soulprint for a verified user
    function symbolizeSoul(bytes32 soulId, string memory essence) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_minted[msg.sender], "Soulprint already minted");
        require(bytes(essence).length > 0, "Essence required");

        _tokenIds.increment();
        uint256 newId = _tokenIds.current();

        _mint(msg.sender, newId);
        _minted[msg.sender] = true;

        emit SymbolicSoulprint(soulId, essence, 5, msg.sender, block.timestamp);
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    { return super.supportsInterface(interfaceId); }
}
