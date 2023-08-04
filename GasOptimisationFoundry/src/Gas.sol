// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

// import "./Ownable.sol";

contract GasContract {
    error NotAdmin();
    error NotSender();
    error NotWhitelisted();
    error InvalidTier();
    error InvalidAddress();
    error InsufficientBalance();
    error NameTooLong();
    error InvalidId();
    error InvalidAmount();
    error ImpossibleError();

    uint256 public constant TRADE_FLAG = 1;
    uint256 public constant BASIC_FLAG = 0;
    uint256 public constant DIVIDEND_FLAG = 1;
    uint256 public totalSupply = 0; // cannot be updated
    uint256 public paymentCounter = 0;
    uint256 public tradePercent = 12;
    uint256 public tradeMode = 0;
    uint256 wasLastOdd = 1;
    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    mapping(address => uint256) public isOddWhitelistUser;
    mapping(address => ImportantStruct) public whiteListStruct;
    address[5] public administrators;
    address public contractOwner;
    bool public isReady = false;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event supplyChanged(address indexed, uint256 indexed);
    event Transfer(address recipient, uint256 amount);
    event PaymentUpdated(address admin, uint256 ID, uint256 amount, string recipient);
    event WhiteListTransfer(address indexed);

    struct Payment {
        PaymentType paymentType;
        uint256 paymentID;
        uint256 amount;
        bool adminUpdated;
        string recipientName; // max 8 characters
        address recipient;
        address admin; // administrators address
    }

    struct History {
        uint256 lastUpdate;
        uint256 blockNumber;
        address updatedBy;
    }

    struct ImportantStruct {
        uint256 amount;
        uint256 valueA; // max 3 digits
        uint256 bigValue;
        uint256 valueB; // max 3 digits
        bool paymentStatus;
        address sender;
    }

    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend,
        GroupPayment
    }

    PaymentType constant defaultPayment = PaymentType.Unknown;

    History[] public paymentHistory; // when a payment was updated

    modifier onlyAdminOrOwner() {
        if (checkForAdmin(msg.sender)) {
            if (!checkForAdmin(msg.sender)) {
                revert NotAdmin();
            }
            _;
        } else if (msg.sender == contractOwner) {
            _;
        } else {
            revert NotAdmin();
        }
    }

    modifier checkIfWhiteListed(address sender) {
        if (msg.sender != sender) {
            revert NotSender();
        }
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
                        emit supplyChanged(_admins[i], totalSupply);
                    } else {
                        balances[_admins[i]] = 0;
                        emit supplyChanged(_admins[i], 0);
                    }
                }
            }
        }
    }

    function getPaymentHistory() public payable returns (History[] memory paymentHistory_) {
        return paymentHistory;
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        bool admin = false;
        unchecked {
            for (uint256 i = 0; i < administrators.length; ++i) {
                if (administrators[i] == _user) {
                    admin = true;
                }
            }
        }
        return admin;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        uint256 balance = balances[_user];
        return balance;
    }

    function getTradingMode() public pure returns (bool mode_) {
        bool mode = false;
        if (TRADE_FLAG == 1 || DIVIDEND_FLAG == 1) {
            mode = true;
        } else {
            mode = false;
        }
        return mode;
    }

    function addHistory(address _updateAddress, bool _tradeMode) public returns (bool status_, bool tradeMode_) {
        History memory history =
            History({blockNumber: block.number, lastUpdate: block.timestamp, updatedBy: _updateAddress});

        paymentHistory.push(history);
        return (true, _tradeMode);
    }

    function getPayments(address _user) public view returns (Payment[] memory payments_) {
        if (_user == address(0)) {
            revert InvalidAddress();
        }
        return payments[_user];
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) public returns (bool) {
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }
        if (bytes(_name).length >= 9) {
            revert NameTooLong();
        }
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }

        emit Transfer(_recipient, _amount);

        Payment memory payment = Payment({
            admin: address(0),
            adminUpdated: false,
            paymentType: PaymentType.BasicPayment,
            recipient: _recipient,
            amount: _amount,
            recipientName: _name,
            paymentID: ++paymentCounter
        });

        payments[msg.sender].push(payment);

        return true;
    }

    function updatePayment(address _user, uint256 _ID, uint256 _amount, PaymentType _type) public onlyAdminOrOwner {
        if (_ID <= 0) {
            revert InvalidId();
        }
        if (_amount <= 0) {
            revert InvalidAmount();
        }
        if (_user == address(0)) {
            revert InvalidAddress();
        }

        unchecked {
            for (uint256 i = 0; i < payments[_user].length; ++i) {
                if (payments[_user][i].paymentID == _ID) {
                    payments[_user][i].adminUpdated = true;
                    payments[_user][i].admin = _user;
                    payments[_user][i].paymentType = _type;
                    payments[_user][i].amount = _amount;
                    bool tradingMode = getTradingMode();
                    addHistory(_user, tradingMode);
                    emit PaymentUpdated(msg.sender, _ID, _amount, payments[_user][i].recipientName);
                }
            }
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public onlyAdminOrOwner {
        if (_tier >= 255) {
            revert InvalidTier();
        }

        if (_tier > 3) {
            whitelist[_userAddrs] = 3;
        } else if (_tier >= 1 && _tier <= 3) {
            whitelist[_userAddrs] = _tier;
        } else {
            whitelist[_userAddrs] = 0;
        }

        wasLastOdd = 1 - wasLastOdd;
        isOddWhitelistUser[_userAddrs] = wasLastOdd;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public checkIfWhiteListed(msg.sender) {
        if (_amount <= 3) {
            revert InvalidAmount();
        }
        if (balances[msg.sender] < _amount) {
            revert InsufficientBalance();
        }
        uint256 senderWhitelistAmount = whitelist[msg.sender];
        uint256 senderFinalBalance = balances[msg.sender] - _amount + senderWhitelistAmount;
        uint256 recipientFinalBalance = balances[_recipient] + _amount - senderWhitelistAmount;
        balances[msg.sender] = senderFinalBalance;
        balances[_recipient] = recipientFinalBalance;
        whiteListStruct[msg.sender] = ImportantStruct(_amount, 0, 0, 0, true, msg.sender);
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (whiteListStruct[sender].paymentStatus, whiteListStruct[sender].amount);
    }

    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }

    fallback() external payable {
        payable(msg.sender).transfer(msg.value);
    }
}
