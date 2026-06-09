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

    /// @notice Tests successful voter registration by the owner
    /// @dev The owner adds Alice to the whitelist
    function testOwnerCanRegisterVoter() public {
        vm.prank(owner);

        voting.whitelistAdd(alice);
    }

    /// @notice Tests that a non-owner cannot register a voter
    /// @dev Expects a revert because only the owner can call whitelistAdd
    function testNonOwnerCannotRegisterVoter() public {
        vm.prank(alice);

        vm.expectRevert();

        voting.whitelistAdd(bob);
    }
}
