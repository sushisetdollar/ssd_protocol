/*
    Copyright 2021 Sushi Set Devs, based on the works of the Empty Set Squad

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "./Bonding.sol";
import "./Govern.sol";
import "../Constants.sol";

contract Implementation is State, Bonding, Market, Regulator, Govern {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() initializer public {
      // committer reward:
      mintToAccount(msg.sender, 50e18); // 50 SSD to committer
    }

    function advance() external {
        Bonding.step();
        Regulator.step();
        Market.step();

        uint256 incentive = Constants.getAdvanceIncentive(); // 60e18
        uint256 price = Regulator.getOraclePrice(); // 1.54$ = 154e16
        uint256 reward = incentive.mul(1e18).div(price);

        mintToAccount(msg.sender, reward);

        emit Incentivization(msg.sender, reward);
        emit Advance(epoch(), block.number, block.timestamp);
    }

}
