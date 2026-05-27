// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

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

    uint256 winningProposalId;

    mapping(address => Voter) voters;

    Proposal[] proposals;

    WorkflowStatus workflowStatus;

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

    function addProposal(string memory description) public {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration not started");

        require(voters[msg.sender].isRegistered, "Voter must be registered");

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
}

