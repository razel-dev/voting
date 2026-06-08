// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./StringUtils.sol";

contract Voting is Ownable {
    constructor() Ownable(msg.sender) {}

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint256 proposalId);
    event Voted(address voter, uint256 proposalId);

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }

    struct Proposal {
        string description;
        uint256 voteCount;
    }

    uint256 internal winningProposalId;

    mapping(address => Voter) internal voters;

    Proposal[] internal proposals;

    WorkflowStatus internal workflowStatus;

    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");
        _;
    }

    function whitelistAdd(address voterAddress) public onlyOwner {
        require(!voters[voterAddress].isRegistered, "Voter already registered");

        voters[voterAddress].isRegistered = true;

        emit VoterRegistered(voterAddress);
    }

    function startProposalRegistration() public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, "Voters registration phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

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

    function addProposal(string memory description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration not started");

        require(voters[msg.sender].isRegistered, "Voter must be registered");

        require(bytes(description).length > 0, "Proposal cannot be empty");

        require(!proposalExists(description), "Proposal already exists");

        proposals.push(Proposal(description, 0));

        uint256 proposalId = proposals.length - 1;

        emit ProposalRegistered(proposalId);
    }

    function endProposalRegistration() public onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposals registration phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    function startVotingSession() public onlyOwner {
        require(
            workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, "Proposals registration phase must be ended"
        );

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.VotingSessionStarted;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

    function endVotingSession() public onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, "Voting session started phase required");

        WorkflowStatus previousStatus = workflowStatus;

        workflowStatus = WorkflowStatus.VotingSessionEnded;

        emit WorkflowStatusChange(previousStatus, workflowStatus);
    }

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

    function tallyVotes() public onlyOwner {
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

    function getWinner() public view returns (Proposal memory) {
        require(workflowStatus == WorkflowStatus.VotesTallied, "Votes not tallied yet");

        return proposals[winningProposalId];
    }

    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    function getProposal(uint256 proposalId) public view returns (Proposal memory) {
        require(proposalId < proposals.length, "Proposal does not exist");

        return proposals[proposalId];
    }

    function getTiedProposals() public view returns (uint256[] memory) {
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
