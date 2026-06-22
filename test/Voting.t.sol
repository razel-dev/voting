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

        assertEq(uint256(voting.getWorkflowStatus()), uint256(Voting.WorkflowStatus.ProposalsRegistrationStarted));
    }

    /// @notice Tests WorkflowStatusChange event emission
    /// @dev Verifies event when proposal registration starts
    function testWorkflowStatusChangeEventOnProposalStart() public {
        vm.expectEmit(true, true, false, true);

        emit Voting.WorkflowStatusChange(
            Voting.WorkflowStatus.RegisteringVoters, Voting.WorkflowStatus.ProposalsRegistrationStarted
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

    /// @notice Tests that an empty proposal is rejected
    /// @dev Expects a revert when submitting an empty proposal
    function testCannotAddEmptyProposal() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);

        vm.expectRevert("Proposal cannot be empty");

        voting.addProposal("");
    }

    /// @notice Tests that duplicate proposals are rejected
    /// @dev Expects a revert when the same proposal is submitted twice
    function testCannotAddDuplicateProposal() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(alice);

        vm.expectRevert("Proposal already exists");

        voting.addProposal("Swimming Pool");
    }

    /// @notice Tests proposal normalization for case differences
    /// @dev "Swimming Pool" and "SWIMMING POOL" must be considered identical
    function testDuplicateProposalWithDifferentCase() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(alice);

        vm.expectRevert("Proposal already exists");

        voting.addProposal("SWIMMING POOL");
    }

    /// @notice Tests proposal normalization for extra spaces
    /// @dev Multiple spaces and surrounding spaces must be ignored
    function testDuplicateProposalWithExtraSpaces() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(alice);

        vm.expectRevert("Proposal already exists");

        voting.addProposal("   Swimming     Pool   ");
    }

    /// @notice Tests proposal normalization for punctuation
    /// @dev Punctuation characters must not create distinct proposals
    function testDuplicateProposalWithPunctuation() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(alice);

        vm.expectRevert("Proposal already exists");

        voting.addProposal("Swimming Pool!!!");
    }

    /// @notice Tests that a registered voter can cast a vote
    /// @dev Alice votes for proposal 0 during voting session
    function testRegisteredVoterCanVote() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);
        voting.setVote(0);
    }

    /// @notice Tests Voted event emission
    /// @dev Event must be emitted when Alice votes
    function testVotedEventIsEmitted() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.expectEmit(true, true, false, true);

        emit Voting.Voted(alice, 0);

        vm.prank(alice);

        voting.setVote(0);
    }

    /// @notice Tests that a voter cannot vote twice
    /// @dev Expects a revert on second vote attempt
    function testCannotVoteTwice() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);
        voting.setVote(0);

        vm.prank(alice);

        vm.expectRevert("Voter already voted");

        voting.setVote(0);
    }

    /// @notice Tests voting for a non-existing proposal
    /// @dev Expects a revert when proposal id is invalid
    function testCannotVoteForNonExistingProposal() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);

        vm.expectRevert("Proposal does not exist");

        voting.setVote(99);
    }

    /// @notice Tests voting outside voting session
    /// @dev Expects a revert because voting session has not started
    function testCannotVoteOutsideVotingSession() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(alice);

        vm.expectRevert("Voting session not started");

        voting.setVote(0);
    }

    /// @notice Tests winner determination after vote tallying
    /// @dev Proposal with highest vote count must be returned
    function testWinnerIsCorrectlyDetermined() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.whitelistAdd(bob);

        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(bob);
        voting.addProposal("Playground");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);
        voting.setVote(1);

        vm.prank(bob);
        voting.setVote(1);

        vm.startPrank(owner);

        voting.endVotingSession();
        voting.tallyVotes();

        vm.stopPrank();

        Voting.Proposal memory winner = voting.getWinner();

        assertEq(winner.description, "playground");
        assertEq(winner.voteCount, 2);
    }

    /// @notice Tests that winner cannot be retrieved before tallying
    /// @dev Expects a revert if votes have not been tallied
    function testCannotGetWinnerBeforeTally() public {
        vm.expectRevert("Votes not tallied yet");

        voting.getWinner();
    }

    /// @notice Tests tied proposal detection
    /// @dev Two proposals receive the same number of votes
    function testDetectTiedProposals() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.whitelistAdd(bob);

        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(bob);
        voting.addProposal("Playground");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);
        voting.setVote(0);

        vm.prank(bob);
        voting.setVote(1);

        uint256[] memory tied = voting.getTiedProposals();

        assertEq(tied.length, 2);
        assertEq(tied[0], 0);
        assertEq(tied[1], 1);
    }

    /// @notice Tests tie detection when no tie exists
    /// @dev Function must return an empty array
    function testNoTieReturnsEmptyArray() public {
        vm.startPrank(owner);

        voting.whitelistAdd(alice);
        voting.whitelistAdd(bob);
        voting.whitelistAdd(charlie);

        voting.startProposalRegistration();

        vm.stopPrank();

        vm.prank(alice);
        voting.addProposal("Swimming Pool");

        vm.prank(bob);
        voting.addProposal("Playground");

        vm.startPrank(owner);

        voting.endProposalRegistration();
        voting.startVotingSession();

        vm.stopPrank();

        vm.prank(alice);
        voting.setVote(0);

        vm.prank(bob);
        voting.setVote(0);

        vm.prank(charlie);
        voting.setVote(1);

        uint256[] memory tied = voting.getTiedProposals();

        assertEq(tied.length, 0);
    }
}
