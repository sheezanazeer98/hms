// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract SignatureVerifier {
    function _verify(
        address _signer,
        bytes32 _ethSignedMessageHash,
        bytes32 r,
        bytes32 s,
        uint8 v
    ) internal pure returns (bool) {
        return ecrecover(_ethSignedMessageHash, v, r, s) == _signer;
    }
}
