// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./util/DelegateERC20.sol";


contract NuLinkToken is DelegateERC20, Ownable {
    uint256 private constant maxSupply =    1000000000 * 1e18;     // the total supply

    constructor()  ERC20("NuLink token", "NLK"){
        super._mint(msg.sender, maxSupply);
    }

    function transfer(address to, uint256 amount) public override returns (bool){
        super._transfer(msg.sender,to,amount);
        return true;
    }


    function transferFrom(address from, address to, uint256 amount) public override returns (bool){
        address spender = super._msgSender();
        super._spendAllowance(from, spender, amount);
        super._transfer(from, to, amount);
        return true;
    }

    

}