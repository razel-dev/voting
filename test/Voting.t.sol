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

/// @notice Tests that VoterRegistered event is emitted
/// @dev The owner registers Alice and the event must be emitted
function testVoterRegisteredEventIsEmitted() public {
    vm.expectEmit(true, false, false, true);

    emit Voting.VoterRegistered(alice);

    vm.prank(owner);

    voting.whitelistAdd(alice);
}

/// @notice Tests that a voter cannot be registered twice
/// @dev Expects a revert when registering the same voter again
function testCannotRegisterSameVoterTwice() public {
    vm.startPrank(owner);

    voting.whitelistAdd(alice);

    vm.expectRevert("Voter already registered");

    voting.whitelistAdd(alice);

    vm.stopPrank();
}
}
