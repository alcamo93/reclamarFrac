// SPDX-License-Identifier: MIT
/**
 * @file reclamarFrac.sol
 * @autor A.Castellano <alcamo93@suissistemas.com>
 * @date created 1th Jul 2022
 * @date last modified 11th Jul 2022
 */

pragma solidity ^0.8.2;

import "./helper_contracts/contracts/token/ERC721/ERC721.sol";
import "./helper_contracts/contracts/token/ERC20/ERC20.sol";
import "./helper_contracts/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./helper_contracts/contracts/utils/math/SafeMath.sol";

contract reclamarFrac {

    using SafeMath for uint256;

    address payable public ownerAddress;
    address public nftAddress;
    address public tokenAddress;
    enum ClaimState {initiated, accepting, closed}
    ClaimState public claimState;
    uint256 public funds;
    uint256 public supply;

    event funded();
    //este contrato de reclamar fracciones solo debe permitirse si la persona que lo inició posee este token NFT
    //this claims contract should only be allowed if the guy who started it owns this NFT token
    modifier isOwnerOfNFT(address _nftAddress, address _ownerAddress, uint256 _tokenID){
        require(ERC721(_nftAddress).ownerOf(_tokenID) == _ownerAddress);
        _;
    }

	modifier condition(bool _condition) {
		require(_condition);
		_;
	}
	modifier onlyOwner() {
		require(msg.sender == ownerAddress);
		_;
	}

    modifier inClaimState(ClaimState _state) {
		require(claimState == _state);
		_;
	}

    modifier correctToken(address _token){
        require(_token == tokenAddress);
        _;
    }

    constructor(address _nftAddress, uint256 _tokenID)
        isOwnerOfNFT(_nftAddress, msg.sender, _tokenID)
    {
        nftAddress = _nftAddress;
        ownerAddress = payable(msg.sender);
        claimState = ClaimState.initiated;
    }

    function fund(address _token)
        public
        payable
        inClaimState(ClaimState.initiated)
        onlyOwner
    {
        funds = msg.value;                                                //cantidad agregada para permitir que se hagan reclamos //amount added to allow claims to be made
        tokenAddress = _token;                                            //dirección del token aceptable //address of acceptable token
        claimState = ClaimState.accepting;                                //establece en estado aceptación//set to accepting status

        supply = ERC20(_token).totalSupply().div(1000000000000000000);    //encuentra cuantas fichas hay //find out how many tokens are out there

        emit funded();
    }

    function claim(address _token, uint256 _amount)
        public
        payable
        correctToken(_token)
    {
        ERC20Burnable(_token).transferFrom(msg.sender, address(this), _amount*1000000000000000000); //recolectar el token, aún no funciona //collect the token back, not working yet
        ERC20Burnable(_token).burn( _amount*1000000000000000000);                                   // reclamado, así que quema este token //claimed, so burn this token
        payable(msg.sender).transfer((_amount*1000000000000000000).div(supply));                    //enviar el ETH al reclama //send the ETH to the claimant

        //ok, fully claimed. Close this contract
        if (ERC20Burnable(_token).totalSupply() == 0){
            claimState = ClaimState.closed;
        }
    }
}
