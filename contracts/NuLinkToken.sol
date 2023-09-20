// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./util/DelegateERC20.sol";


interface IMintToken is IERC20 {
    function mint(address to, uint256 amount) external returns (bool);
}

contract NuLinkToken is DelegateERC20,IMintToken, Ownable {
    uint256 private  preMineSupply ;
    uint256 private constant maxSupply =    1000000000 * 1e18;     // the total supply

    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _minters;
    mapping(address=>uint256) public minerSetTime;
    
    event SetMinerTime(address _addMinter,uint256 _time);
    

    constructor(uint256 _preMineSupply)  ERC20("NuLink token", "NLK"){
        preMineSupply = _preMineSupply ;
        _mint(msg.sender, preMineSupply);
    }

    // mint with max supply
    function mint(address _to, uint256 _amount) external onlyMinter override  returns (bool) {
        require (_amount+totalSupply() <= maxSupply) ;
        _mint(_to, _amount);
        return true;
    }

    function addMinter(address _addMinter) public onlyOwner returns (bool) {
        require(_addMinter != address(0), "NuLinktoken: _addMinter is the zero address");
        minerSetTime[_addMinter] = block.timestamp;
        
        emit SetMinerTime(_addMinter,block.timestamp);
        return EnumerableSet.add(_minters, _addMinter);
    }

    function delMinter(address _delMinter) public onlyOwner returns (bool) {
        require(_delMinter != address(0), "NuLinktoken: _delMinter is the zero address");
        
        minerSetTime[_delMinter] = 0;
        
        emit SetMinerTime(_delMinter,0);
        return EnumerableSet.remove(_minters, _delMinter);
    }

    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(_minters);
    }

    function isMinter(address account) public view returns (bool) {
        return EnumerableSet.contains(_minters, account);
    }

    function getMinter(uint256 _index) public view onlyOwner returns (address){
        require(_index <= getMinterLength() - 1, "NuLinktoken: index out of bounds");
        return EnumerableSet.at(_minters, _index);
    }

    // modifier for mint function
    modifier onlyMinter() {
        require(isMinter(msg.sender)&& minerSetTime[msg.sender]+86400 <= block.timestamp, "NuLinktoken:caller is not the minter");
        _;
    }

}