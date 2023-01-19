// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {StakingContract} from "../src/StakingContract.sol";

contract StakingContractTest is Test {
    event Stake(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    Token public token;
    StakingContract public stakingContract;
    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    function setUp() public {
        vm.prank(alice);
        token = new Token();
        stakingContract = new StakingContract(token);
    }

    function testStakingShouldBeSuccesful(uint256 _stake) public {
        _stake = bound(_stake, 1, 1_000_000);

        vm.startPrank(alice);
        token.approve(address(stakingContract), type(uint256).max);

        vm.expectEmit(false, false, false, true);
        emit Stake(alice, _stake);

        stakingContract.stake(_stake);
        vm.stopPrank();

        (uint256 amount, uint256 snap) = stakingContract.stakingRecords(alice);

        assertEq(amount, _stake);
        assertEq(snap, 0);
    }

    function testWithdrawingShouldBeSuccesful(uint256 _stake) public {
        _stake = bound(_stake, 1, 1_000_000);
        // All of this is done by Alice
        vm.startPrank(alice);
        // 1. Approve the ERC20 to transfer the tokens
        token.approve(address(stakingContract), _stake);
        // 2. Call the staking contract
        stakingContract.stake(_stake);
        // Event to happen
        vm.expectEmit(false, false, false, true);
        emit Withdraw(alice, _stake);
        stakingContract.withdraw();
        // Should end up with the same amount of tokens
        (uint256 currentStake,) = stakingContract.stakingRecords(alice);
        // Shouldn't have any tokens staked now
        assertEq(currentStake, 0);
    }

    function testFailToDistributeWithoutStakers(uint256 _reward) public {
        _reward = bound(_reward, 1, 1_000_000);
        // Alice wants to give out of her tokens to the active stakers
        vm.startPrank(alice);
        token.approve(address(stakingContract), _reward);
        // Can't distribute if there are no stakers
        stakingContract.distribute(_reward);
    }

    function testDistributingTokensCorrectly() public {
        // 1. Someone needs to stake
        vm.startPrank(alice);
        token.approve(address(stakingContract), 500_000);
        stakingContract.stake(500_000);
        // gift bob half of her tokens
        token.transfer(bob, 500_000);
        // 2. Bob plays the part of the philantropist
        changePrank(bob);
        token.approve(address(stakingContract), 500_000);
        stakingContract.distribute(500_000);
        // 3. The staker needs to withdraw and verify the correct amount
        changePrank(alice);
        uint256 currentRewardsPerToken = stakingContract.rewardsPerStakedToken();
        // 500_000 / 500_000 = 1
        assertEq(currentRewardsPerToken, 1);
        // alice should end up with 1_000_000 tokens
        stakingContract.withdraw();
        uint256 aliceTokens = token.balanceOf(alice);
        assertEq(aliceTokens, 1_000_000);
    }
}
