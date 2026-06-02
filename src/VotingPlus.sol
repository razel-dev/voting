// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Voting.sol";

/// @title VotingPlus
/// @author Rafael Alcaniz
/// @notice Enhanced voting contract with additional validations and utility functions
/// @dev Adds onlyVoter modifier, proposal validation, duplicate detection,
/// proposal description normalization and proposal getter functions

contract VotingPlus is Voting {
    /// @notice Restricts access to registered voters only
    /// @dev Checks if the sender is a registered voter before allowing function execution
    modifier onlyVoter() {
        require(voters[msg.sender].isRegistered, "Voter must be registered");

        _;
    }

    /// @notice Checks whether a proposal already exists
    /// @param description The proposal description to search for
    /// @return True if an identical proposal already exists, otherwise false
    /// @dev Compares normalized descriptions using keccak256 hashes because Solidity does not support direct string comparison
    function proposalExists(string memory description) private view returns (bool) {
        for (uint256 i = 0; i < proposals.length; i++) {
            if (
                keccak256(bytes(normalizeDescription(proposals[i].description)))
                    == keccak256(bytes(normalizeDescription(description)))
            ) {
                return true;
            }
        }

        return false;
    }

    /// @notice Normalizes a proposal description
    /// @param description Description to normalize
    /// @return Normalized description
    /// @dev Converts uppercase ASCII letters to lowercase, trims leading/trailing spaces and collapses multiple spaces into a single space
    function normalizeDescription(string memory description) private pure returns (string memory) {
        bytes memory data = bytes(description);

        // Lowercase conversion
        for (uint256 i = 0; i < data.length; i++) {
            if (uint8(data[i]) >= 65 && uint8(data[i]) <= 90) {
                data[i] = bytes1(uint8(data[i]) + 32);
            }
        }

        // Empty string
        if (data.length == 0) {
            return "";
        }

        // Find first non-space character
        uint256 start = 0;

        while (start < data.length && uint8(data[start]) == 32) {
            start++;
        }

        // String contains only spaces
        if (start == data.length) {
            return "";
        }

        // Find last non-space character
        uint256 end = data.length - 1;

        while (end > start && uint8(data[end]) == 32) {
            end--;
        }

        // Trim
        bytes memory trimmed = new bytes(end - start + 1);

        for (uint256 i = start; i <= end; i++) {
            trimmed[i - start] = data[i];
        }

        // Normalize internal whitespace
        bool previousWasSpace = false;

        bytes memory normalized = new bytes(trimmed.length);

        uint256 normalizedLength = 0;

        for (uint256 i = 0; i < trimmed.length; i++) {
            if (uint8(trimmed[i]) == 32) {
                if (!previousWasSpace) {
                    normalized[normalizedLength] = trimmed[i];

                    normalizedLength++;

                    previousWasSpace = true;
                }
            } else {
                normalized[normalizedLength] = trimmed[i];

                normalizedLength++;

                previousWasSpace = false;
            }
        }

        bytes memory result = new bytes(normalizedLength);

        for (uint256 i = 0; i < normalizedLength; i++) {
            result[i] = normalized[i];
        }

        return string(result);
    }

    /// @notice Adds a new proposal
    /// @param description The description of the proposal to be added
    /// @dev Validates that the proposal description is not empty before adding it to the proposals array
    /// @dev Checks for duplicate proposals by comparing the description with existing proposals to prevent adding the same proposal multiple times
    function addProposal(string memory description) public override {
        require(bytes(description).length > 0, "Proposal cannot be empty");

        require(!proposalExists(description), "Proposal already exists");

        super.addProposal(description);
    }

    /// @notice Returns the total number of proposals
    /// @return Total number of registered proposals
    /// @dev Returns the length of the proposals array to indicate how many proposals have been added
    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }

    /// @notice Returns a proposal by its identifier
    /// @param proposalId Identifier of the proposal
    /// @return Requested proposal
    /// @dev Validates that the proposal ID is within the bounds of the proposals array before returning the proposal
    function getProposal(uint256 proposalId) public view returns (Proposal memory) {
        require(proposalId < proposals.length, "Proposal does not exist");

        return proposals[proposalId];
    }
}
