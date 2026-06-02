// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

/// @title StringUtils
/// @author Rafael Alcaniz
/// @notice Utility library for string normalization
/// @dev Provides reusable text normalization functions

library StringUtils {
    /// @notice Normalizes a string
    /// @param description Text to normalize
    /// @return Normalized text
    /// @dev Converts uppercase ASCII letters to lowercase, trims leading/trailing spaces,
    /// collapses multiple spaces into a single space and removes punctuation characters
    function normalize(string memory description) internal pure returns (string memory) {
        bytes memory data = bytes(description);

        // Lowercase conversion
        for (uint256 i = 0; i < data.length; i++) {
            if (uint8(data[i]) >= 65 && uint8(data[i]) <= 90) {
                data[i] = bytes1(uint8(data[i]) + 32);
            }
        }

        if (data.length == 0) {
            return "";
        }

        uint256 start = 0;

        while (start < data.length && uint8(data[start]) == 32) {
            start++;
        }

        if (start == data.length) {
            return "";
        }

        uint256 end = data.length - 1;

        while (end > start && uint8(data[end]) == 32) {
            end--;
        }

        bytes memory trimmed = new bytes(end - start + 1);

        for (uint256 i = start; i <= end; i++) {
            trimmed[i - start] = data[i];
        }

        bool previousWasSpace = false;

        bytes memory normalized = new bytes(trimmed.length);

        uint256 normalizedLength = 0;

        for (uint256 i = 0; i < trimmed.length; i++) {
            uint8 charCode = uint8(trimmed[i]);

            if (
                charCode == 33 || charCode == 44 || charCode == 46 || charCode == 58 || charCode == 59 || charCode == 63
            ) {
                continue;
            }

            if (charCode == 32) {
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
}
