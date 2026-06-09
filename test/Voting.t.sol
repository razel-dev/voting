// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test {
    Voting voting;

    address owner = address(1);
    address alice = address(2);
    address bob = address(3);
    address charlie = address(4);

    function setUp() public {
        vm.prank(owner);

        voting = new Voting();
    }
}
