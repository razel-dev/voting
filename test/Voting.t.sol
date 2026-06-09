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

/// @notice Tests that voter registration is forbidden after registration phase
/// @dev Expects a revert when attempting to register a voter after proposal registration has started
function testCannotRegisterVoterAfterRegistrationPhase() public {
    vm.startPrank(owner);

    voting.startProposalRegistration();

    vm.expectRevert("Voters registration phase required");

    voting.whitelistAdd(alice);

    vm.stopPrank();
}

/// @notice Tests successful start of proposal registration phase
/// @dev Verifies workflow status transition
function testStartProposalRegistration() public {
    vm.prank(owner);

    voting.startProposalRegistration();

    assertEq(
        uint256(voting.getWorkflowStatus()),
        uint256(Voting.WorkflowStatus.ProposalsRegistrationStarted)
    );
}

/// @notice Tests WorkflowStatusChange event emission
/// @dev Verifies event when proposal registration starts
function testWorkflowStatusChangeEventOnProposalStart() public {
    vm.expectEmit(true, true, false, true);

    emit Voting.WorkflowStatusChange(
        Voting.WorkflowStatus.RegisteringVoters,
        Voting.WorkflowStatus.ProposalsRegistrationStarted
    );

    vm.prank(owner);

    voting.startProposalRegistration();
}

/// @notice Tests that a registered voter can add a proposal
/// @dev Alice registers a proposal during proposal registration phase
function testRegisteredVoterCanAddProposal() public {
    vm.startPrank(owner);

    voting.whitelistAdd(alice);
    voting.startProposalRegistration();

    vm.stopPrank();

    vm.prank(alice);

    voting.addProposal("Swimming Pool");

    assertEq(voting.getProposalCount(), 1);
}

/// @notice Tests ProposalRegistered event emission
/// @dev Event must be emitted when a proposal is successfully registered
function testProposalRegisteredEventIsEmitted() public {
    vm.startPrank(owner);

    voting.whitelistAdd(alice);
    voting.startProposalRegistration();

    vm.stopPrank();

    vm.expectEmit(true, false, false, true);

    emit Voting.ProposalRegistered(0);

    vm.prank(alice);

    voting.addProposal("Swimming Pool");
}

/// @notice Tests that an unregistered user cannot add a proposal
/// @dev Expects a revert because Bob is not registered
function testNonRegisteredUserCannotAddProposal() public {
    vm.prank(owner);

    voting.startProposalRegistration();

    vm.expectRevert("Voter must be registered");

    vm.prank(bob);

    voting.addProposal("Swimming Pool");
}
}
