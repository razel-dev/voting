// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Voting.sol";

contract VotingPlus is Voting {
    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");

        _;
    }
}
