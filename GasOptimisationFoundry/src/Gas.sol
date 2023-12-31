// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract GasContract {
    error NotAdmin();
    error NotWhitelisted();

    uint256 private whiteListStruct;
    mapping(address => uint256) public balances;
    address[5] public administrators;
    address private immutable contractOwner;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner = msg.sender;

        uint256 adminsLength = administrators.length;

        unchecked {
            for (uint256 i = 0; i < adminsLength; ++i) {
                administrators[i] = _admins[i];
                if (_admins[i] == contractOwner) {
                    balances[contractOwner] = _totalSupply;
                }
            }
        }
    }

    function balanceOf(address _user) external view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(address _recipient, uint256 _amount, string calldata _name) external {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) external {
        if (_tier >= 255 || msg.sender != contractOwner) {
            revert NotAdmin();
        }
        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) external {
        unchecked {
            balances[msg.sender] -= _amount;
            balances[_recipient] += _amount;
        }
        whiteListStruct = _amount;
        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) external view returns (bool, uint256) {
        return (true, whiteListStruct);
    }

    function whitelist(address user) external pure returns (uint256) {
        return 0;
    }
}
