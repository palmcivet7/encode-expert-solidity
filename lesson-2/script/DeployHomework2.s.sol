// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Homework2} from "../src/Homework2.sol";

contract DeployHomework2 is Script {
    function run() external returns (Homework2) {
        vm.startBroadcast();
        Homework2 homework = new Homework2();
        vm.stopBroadcast();

        return (homework);
    }
}
