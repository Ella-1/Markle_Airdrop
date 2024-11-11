// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

// import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC20,SafeERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
contract MarkleAirdrop {
   using SafeERC20 for IERC20;

    error  MarkleAirdrop__InvalidProof();
    error MarkleAirdrop__AlreadyClaimed();

    event claims(address indexed account, uint256 indexed  amount);
    // allows someone to claim the list of erc20
    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;
    mapping (address claimer => bool claimed) private s_hasClaimed;

    constructor(bytes32 _markleRoot, IERC20 _airdropToken) {
        i_merkleRoot = _markleRoot;
        i_airdropToken = _airdropToken;
    }

    function claim(address _account, uint256 _amount, bytes32[] calldata _markleProof) external{
        if(s_hasClaimed[_account]) {
            revert MarkleAirdrop__AlreadyClaimed();
        }
        // we hash it twice to avoid collusion
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account,_amount))));

        // now we verify the proof
        if(!MerkleProof.verify(_markleProof,i_merkleRoot,leaf)){
            revert MarkleAirdrop__InvalidProof();
        }

        emit claims(_account,_amount);
        i_airdropToken.safeTransfer(_account,_amount);
        s_hasClaimed[_account] = true;
    }

    function getMerkleRoot() external view returns(bytes32) {
        return i_merkleRoot;
    }

    function getAirdrop() external view returns(IERC20){
        return i_airdropToken;
    }

}