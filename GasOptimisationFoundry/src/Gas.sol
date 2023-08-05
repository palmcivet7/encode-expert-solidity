// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract GasContract {
    error NotAdmin();
    error NotSender();
    error NotWhitelisted();
    error InvalidTier();

    uint256 public immutable totalSupply; // cannot be updated
    uint8 public constant tradePercent = 12;
    uint8 public constant tradeMode = 0;
    bool public isReady = false;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;
    mapping(address => ImportantStruct) public whiteListStruct;
    address[5] public administrators;
    address public immutable contractOwner;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    struct ImportantStruct {
        uint256 amount;
        address sender;
        bool paymentStatus;
    }

    modifier onlyAdminOrOwner() {
        if (msg.sender == contractOwner) {
            _;
        } else {
            revert NotAdmin();
        }
    }

    modifier checkIfWhiteListed(address sender) {
        uint256 usersTier = whitelist[msg.sender];
        if (usersTier <= 0) {
            revert NotWhitelisted();
        }
        if (usersTier >= 4) {
            revert InvalidTier();
        }
        _;
    }

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;
        totalSupply = _totalSupply;

        unchecked {
            for (uint256 i = 0; i < administrators.length; ++i) {
                if (_admins[i] != address(0)) {
                    administrators[i] = _admins[i];
                    if (_admins[i] == contractOwner) {
                        balances[contractOwner] = totalSupply;
                    } else {
                        balances[_admins[i]] = 0;
                    }
                }
            }
        }
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) external returns (bool) {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
        return true;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external onlyAdminOrOwner {
        if (_tier >= 255) {
            revert InvalidTier();
        }
        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        } else if (_tier >= 1) {
            whitelist[_userAddrs] = _tier;
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) external checkIfWhiteListed(msg.sender) {
        uint256 senderWhitelistAmount = whitelist[msg.sender];
        unchecked {
            uint256 senderFinalBalance = balances[msg.sender] - _amount + senderWhitelistAmount;
            uint256 recipientFinalBalance = balances[_recipient] + _amount - senderWhitelistAmount;

            balances[msg.sender] = senderFinalBalance;
            balances[_recipient] = recipientFinalBalance;
        }
        whiteListStruct[msg.sender] = ImportantStruct(_amount, msg.sender, true);
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) external view returns (bool, uint256) {
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }
}
