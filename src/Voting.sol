// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./StringUtils.sol";

/// @title Voting
/// @author Rafael Alcaniz
/// @notice Smart contract implementing a complete voting workflow
/// @dev Supports voter registration, proposal registration,
/// voting, vote tallying, duplicate proposal detection
/// and tie detection
contract Voting is Ownable {
    constructor() Ownable(msg.sender) {}

    /// @notice Defines the different workflow phases
    /// of the voting process
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    /// @notice Emitted when a voter is registered
    /// @param voterAddress Address of the registered voter
    event VoterRegistered(address voterAddress);

    /// @notice Emitted when workflow status changes
    /// @param previousStatus Previous workflow phase
    /// @param newStatus New workflow phase
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    /// @notice Emitted when a proposal is registered
    /// @param proposalId Identifier of the proposal
    event ProposalRegistered(uint256 proposalId);

    /// @notice Emitted when a vote is cast
    /// @param voter Address of the voter
    /// @param proposalId Identifier of the selected proposal
    event Voted(address voter, uint256 proposalId);

    /// @notice Represents a registered voter
    /// @dev Stores registration and voting information
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    /// @notice Represents a proposal
    /// @dev Stores proposal details and vote count
    struct Proposal {
        string description;
        uint256 voteCount;
    }

    /// @notice Identifier of the winning proposal
    uint256 internal winningProposalId;

    /// @notice Registered voters
    mapping(address => Voter) internal voters;

    /// @notice Registered proposals
    Proposal[] internal proposals;

    /// @notice Current workflow phase
    WorkflowStatus internal workflowStatus;

    /// @notice Restricts access to registered voters
    /// @dev Reverts if sender is not registered
    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");
        _;
    }

    /// @notice Registers a voter
    /// @param voterAddress Address of the voter
    /// @dev Can only be called by the owner during
    /// the RegisteringVoters phase
    function whitelistAdd(address voterAddress) external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Voters registration phase required");

        require(!voters[voterAddress].isRegistered, "Voter already registered");

        voters[voterAddress].isRegistered = true;

        emit VoterRegistered(voterAddress);
    }

    function startProposalRegistration() external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Voters registration phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    /// @notice Checks whether a proposal already exists
    /// @param description Proposal description
    /// @return True if a duplicate proposal exists
    /// @dev Uses normalized hashes for comparison
    function proposalExists(string memory description) private view returns (bool) {
        for (uint256 i = 0; i < proposals.length; i++) {
            if (
                keccak256(abi.encodePacked(StringUtils.normalize(proposals[i].description)))
                    == keccak256(abi.encodePacked(StringUtils.normalize(description)))
            ) {
                return true;
            }
        }

        return false;
    }

    /// @notice Registers a proposal
    /// @param description Proposal description
    /// @dev Rejects empty and duplicate proposals
    function addProposal(string memory description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration not started");

        require(voters[msg.sender].isRegistered, "Voter must be registered");

        require(bytes(description).length > 0, "Proposal cannot be empty");

        require(!proposalExists(description), "Proposal already exists");

        proposals.push(Proposal(description, 0));

        uint256 proposalId = proposals.length - 1;

        emit ProposalRegistered(proposalId);
    }

    /// @notice Ends proposal registration
    /// @dev Transitions workflow to
    /// ProposalsRegistrationEnded
    function endProposalRegistration() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposals registration phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    /// @notice Starts voting session
    /// @dev Transitions workflow to VotingSessionStarted
    function startVotingSession() external onlyOwner {
        require(
            workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, "Proposals registration phase must be ended"
        );

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.VotingSessionStarted;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    /// @notice Ends voting session
    /// @dev Transitions workflow to VotingSessionEnded

    function endVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "Voting session started phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.VotingSessionEnded;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    /// @notice Casts a vote
    /// @param votedProposalId Selected proposal identifier
    /// @dev Each voter can vote only once
    function setVote(uint256 votedProposalId) public {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "Voting session not started");

        require(voters[msg.sender].isRegistered, "Voter must be registered");

        require(!voters[msg.sender].hasVoted, "Voter already voted");

        require(votedProposalId < proposals.length, "Proposal does not exist");

        voters[msg.sender].hasVoted = true;

        voters[msg.sender].votedProposalId = votedProposalId;

        proposals[votedProposalId].voteCount++;

        emit Voted(msg.sender, votedProposalId);
    }

    /// @notice Tallies votes
    /// @dev Determines the proposal having the
    /// highest vote count
    function tallyVotes() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Voting session ended phase required");

        uint256 winningVoteCount = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalId = i;
            }
        }

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.VotesTallied;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    /// @notice Returns current workflow status
    /// @return Current workflow phase
    function getWorkflowStatus() external view returns (WorkflowStatus) {
        return workflowStatus;
    }

    /// @notice Returns the winning proposal
    /// @return Winning proposal
    /// @dev Available only after vote tallying
    function getWinner() external view returns (Proposal memory) {
        require(workflowStatus == WorkflowStatus.VotesTallied, "Votes not tallied yet");

        return proposals[winningProposalId];
    }

    /// @notice Returns total number of proposals
    /// @return Number of proposals
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns a proposal
    /// @param proposalId Proposal identifier
    /// @return Requested proposal
    /// @dev Accessible only to registered voters
    function getProposal(uint256 proposalId) external view onlyVoter returns (Proposal memory) {
        require(proposalId < proposals.length, "Proposal does not exist");

        return proposals[proposalId];
    }

    /// @notice Returns proposals tied for first place
    /// @return Array of proposal identifiers
    /// @dev Returns an empty array when there is no tie
    function getTiedProposals() external view returns (uint256[] memory) {
        uint256 maxVoteCount = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
            }
        }

        uint256 tieCount = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == maxVoteCount) {
                tieCount++;
            }
        }

        if (tieCount < 2) {
            return new uint256[](0);
        }

        uint256[] memory tiedProposals = new uint256[](tieCount);
        uint256 tieIndex = 0;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount == maxVoteCount) {
                tiedProposals[tieIndex] = i;
                tieIndex++;
            }
        }

        return tiedProposals;
    }
}
