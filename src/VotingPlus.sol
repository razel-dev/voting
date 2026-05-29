// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Voting.sol";

contract VotingPlus is Voting {
    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");

        _;
    }

    function addProposal(string memory description) public override {
        require(bytes(description).length > 0, "Proposal cannot be empty");

        super.addProposal(description);
    }
}
