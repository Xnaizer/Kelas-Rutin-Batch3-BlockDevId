// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title CourseBadge
 * @dev Multi-token untuk berbagai badges dan certificates
 * Token types:
 * - Course completion certificates (non-fungible)
 * - Event attendance badges (fungible)
 * - Achievement medals (limited supply)
 * - Workshop participation tokens
 */
contract CourseBadge is ERC1155, AccessControl, Pausable, ERC1155Supply {
    // Role definitions
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Token ID ranges untuk organization
    uint256 public constant CERTIFICATE_BASE = 1000;
    uint256 public constant EVENT_BADGE_BASE = 2000;
    uint256 public constant ACHIEVEMENT_BASE = 3000;
    uint256 public constant WORKSHOP_BASE = 4000;
    
    // Token metadata structure
    struct TokenInfo {
        string name;
        string category;
        uint256 maxSupply;
        bool isTransferable;
        uint256 validUntil; // 0 = no expiry
        address issuer;
    }
    
    // Mappings
    mapping(uint256 => TokenInfo) public tokenInfo;
    mapping(uint256 => string) private _tokenURIs;
    
    // Track student achievements
    mapping(address => uint256[]) public studentBadges;
    mapping(uint256 => mapping(address => uint256)) public earnedAt; // Timestamp
    
    // Tambahan: Mapping untuk data tambahan per sertifikat
    mapping(uint256 => mapping(address => string)) public certificateAdditionalData;
    
    // Counter untuk generate unique IDs
    uint256 private _certificateCounter;
    uint256 private _eventCounter;
    uint256 private _achievementCounter;
    uint256 private _workshopCounter;

    constructor() ERC1155("") {
        // Setup roles
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    /**
     * @dev Create new certificate type
     * Use case: Mata kuliah baru atau program baru
     */
    function createCertificateType(
        string memory _name,
        uint256 _maxSupply,
        string memory _uri
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        // TODO: Create new certificate type
        // 1. Generate ID: CERTIFICATE_BASE + _certificateCounter++
        // 2. Store token info
        // 3. Set URI
        // 4. Return token ID
        require(bytes(_name).length > 0, "Masukkan nama dengan benar!");
        require(_maxSupply > 0, "Masukkan supply dengan benar!");
        require(bytes(_uri).length > 0, "Masukkan Uri dengan benar!");

        uint256 generatedID = CERTIFICATE_BASE + _certificateCounter++;

        tokenInfo[generatedID] = TokenInfo({
            name : _name,
            category:"certificate",
            maxSupply: _maxSupply,
            isTransferable : false,
            validUntil : block.timestamp + 2 * 365 days,// 0 = no expiry
            issuer: msg.sender
        });
        
        _tokenURIs[generatedID] = _uri; // Set URI untuk tipe token ini
        return generatedID;
    }

    /**
     * @dev Issue certificate to student
     * Use case: Student lulus mata kuliah
     */
    function issueCertificate(
        address _student,
        uint256 _certificateType,
        string memory _additionalData
    ) public onlyRole(MINTER_ROLE) {
        // TODO: Mint certificate
        // 1. Verify certificate type exists
        // 2. Check max supply not exceeded
        // 3. Mint 1 token to student
        // 4. Record timestamp
        // 5. Add to student's badge list
        require(_student != address(0), "Masukkan Address dengan benar!");
        require(_certificateType > 0, "Masukkan tipe certificate dengan benar!");
        require(bytes(_additionalData).length > 0, "Masukkan data dengan benar!");
        require(tokenInfo[_certificateType].maxSupply > 0, "Sertifikat ini tidak ditemukan!");
        require(totalSupply(_certificateType) < tokenInfo[_certificateType].maxSupply, "Supply sudah habis!");

        _mint(_student, _certificateType, 1, "");
        earnedAt[_certificateType][_student] = block.timestamp;
        studentBadges[_student].push(_certificateType);

        if(bytes(_additionalData).length > 0) {
           certificateAdditionalData[_certificateType][_student] = _additionalData;
        }
    }

    /**
     * @dev Batch mint event badges
     * Use case: Attendance badges untuk peserta event
     */
    function mintEventBadges(
        address[] memory _attendees,
        uint256 _eventId,
        uint256 _amount
    ) public onlyRole(MINTER_ROLE) {
        // TODO: Batch mint to multiple addresses
        // Use loop to mint to each attendee
        // Record participation
        require(_amount > 0, "Masukkan amount yang benar!");
        require(tokenInfo[_eventId].maxSupply > 0, "Event badge tidak ditemukan!");
        require(totalSupply(_eventId) + (_attendees.length * _amount) <= tokenInfo[_eventId].maxSupply, "Supply sudah habis!");
        
        for (uint256 i = 0; i < _attendees.length; i++) {
            require(_attendees[i] != address(0), "Ada alamat null");
            _mint(_attendees[i], _eventId, _amount, "");
            earnedAt[_eventId][_attendees[i]] = block.timestamp;
            studentBadges[_attendees[i]].push(_eventId);
        }
    }

    /**
     * @dev Set metadata URI untuk token
     */
    function setTokenURI(uint256 _tokenId, string memory _newuri) 
        public onlyRole(URI_SETTER_ROLE) 
    {
        // TODO: Store custom URI per token
        require(_tokenId > 0, "Masukkan data dengan benar!");
        require(bytes(_newuri).length > 0, "Masukkan data dengan benar!");
        _tokenURIs[_tokenId] = _newuri;
    }

    /**
     * @dev Get all badges owned by student
     */
    function getStudentBadges(address _student) 
        public view returns (uint256[] memory) 
    {
        // TODO: Return array of token IDs owned by student
        return studentBadges[_student];
    }

    /**
     * @dev Verify badge ownership dengan expiry check
     */
    function verifyBadge(address _student, uint256 _tokenId) 
        public view returns (bool isValid, uint256 earnedTimestamp) 
    {
        // TODO: Check ownership and validity
        // 1. Check balance > 0
        // 2. Check not expired
        // 3. Return status and when earned
        bool owns = balanceOf(_student, _tokenId) > 0;
        uint256 expiry = tokenInfo[_tokenId].validUntil;
        uint256 earned = earnedAt[_tokenId][_student];
        bool notExpired = expiry == 0 || block.timestamp <= expiry;
        isValid = owns && notExpired;

        return (isValid, earned);
    }

    /**
     * @dev Pause all transfers
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /**
     * @dev Override untuk fungsi _update dari ERC1155 dan ERC1155Supply
     * Di OpenZeppelin v5, kita harus override fungsi ini
     */
    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal virtual override(ERC1155, ERC1155Supply) whenNotPaused {
        // TODO: Check transferability for each token
        if (from != address(0) && to != address(0)) { // Not mint or burn
            for (uint i = 0; i < ids.length; i++) {
                require(tokenInfo[ids[i]].isTransferable, "Token tidak dapat ditransfer");
            }
        }
        
        super._update(from, to, ids, values);
    }

    /**
     * @dev Override to return custom URI per tokens
     */
    function uri(uint256 tokenId) public view override returns (string memory) {
        // TODO: Return stored URI for token
        if(bytes(_tokenURIs[tokenId]).length > 0) { 
            return _tokenURIs[tokenId];
        }
        return super.uri(tokenId);
    }

    /**
     * @dev Check interface support
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Achievement System Functions
    
    /**
     * @dev Grant achievement badge
     * Use case: Dean's list, competition winner, etc
     */
    function grantAchievement(
        address _student,
        string memory _achievementName,
        uint256 _rarity // 1 = common, 2 = rare, 3 = legendary
    ) public onlyRole(MINTER_ROLE) returns (uint256) {
        // TODO: Create unique achievement NFT
        // Generate achievement ID
        // Set limited supply based on rarity
        // Mint to deserving student
        require(_student != address(0), "Masukkan address dengan benar!");
        require(bytes(_achievementName).length > 0, "Nama Invalid!");
        require(_rarity >= 1 && _rarity <=3, "Rarity Invalid");

        uint256 _maxSupplies;
        
        if(_rarity == 1) {
            _maxSupplies = 1000;
        } else if (_rarity == 2) {
            _maxSupplies = 100;
        } else {
            _maxSupplies = 10;
        } 

        uint256 achieveID = ACHIEVEMENT_BASE + _achievementCounter++;
        tokenInfo[achieveID] = TokenInfo({
            name: _achievementName,
            category: "achievement",
            maxSupply: _maxSupplies,
            isTransferable: false,
            validUntil: block.timestamp + 2 * 365 days,
            issuer: msg.sender
        });

        _mint(_student, achieveID, 1, "");
        earnedAt[achieveID][_student] = block.timestamp;
        studentBadges[_student].push(achieveID);

        return achieveID;
    }   

    /**
     * @dev Create workshop series dengan multiple sessions
     */
    function createWorkshopSeries(
        string memory _seriesName,
        uint256 _totalSessions
    ) public onlyRole(MINTER_ROLE) returns (uint256[] memory) {
        // TODO: Create multiple related tokens
        // Return array of token IDs for each session
        require(bytes(_seriesName).length > 0, "Masukkan series nama dengan benar!");
        require(_totalSessions > 0 && _totalSessions <= 500, "Berikan total sesi yang valid!");

        uint256[] memory tokenID = new uint256[](_totalSessions);
        for (uint256 i = 0; i < _totalSessions; i++) {
            uint256 workshopId = WORKSHOP_BASE + _workshopCounter++;
            tokenInfo[workshopId] = TokenInfo({
                name: string(abi.encodePacked(_seriesName, " Sesi #", Strings.toString(i+1))),
                category: "workshop",
                maxSupply: 500, 
                isTransferable: false,
                validUntil: 0,
                issuer: msg.sender
            });
            tokenID[i] = workshopId;
        }
        return tokenID;
    }
}