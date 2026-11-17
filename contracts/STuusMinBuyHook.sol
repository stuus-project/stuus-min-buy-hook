// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/src/types/Currency.sol";

/// @notice Enforces a minimum actual ETH input when buying STUUS from one native ETH/STUUS v4 pool.
/// @dev The hook address must have only Hooks.AFTER_SWAP_FLAG set in its low permission bits.
contract STuusMinBuyHook is Ownable {
    using BalanceDeltaLibrary for BalanceDelta;
    using CurrencyLibrary for Currency;

    error OnlyPoolManager();
    error InvalidPool();
    error InvalidEthDelta();
    error BuyBelowMinimum(uint256 ethSpent, uint256 minimumBuy);

    event MinimumBuyChanged(uint256 oldMinimumBuy, uint256 newMinimumBuy);

    IPoolManager public immutable poolManager;
    address public immutable stuusToken;

    uint256 public minimumBuy = 0.005 ether;

    modifier onlyPoolManager() {
        if (msg.sender != address(poolManager)) revert OnlyPoolManager();
        _;
    }

    constructor(IPoolManager poolManager_, address stuusToken_, address owner_) Ownable(owner_) {
        if (address(poolManager_) == address(0) || stuusToken_ == address(0)) revert InvalidPool();

        poolManager = poolManager_;
        stuusToken = stuusToken_;

        Hooks.validateHookPermissions(IHooks(address(this)), getHookPermissions());
    }

    function getHookPermissions() public pure returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    /// @notice Changes the minimum for future STUUS buys. Set to zero to disable the restriction.
    function setMinimumBuy(uint256 newMinimumBuy) external onlyOwner {
        uint256 oldMinimumBuy = minimumBuy;
        minimumBuy = newMinimumBuy;
        emit MinimumBuyChanged(oldMinimumBuy, newMinimumBuy);
    }

    /// @notice Called by Uniswap v4 after a swap. A revert rolls back the entire swap.
    function afterSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) external onlyPoolManager returns (bytes4, int128) {
        // Native ETH sorts as currency0. A STUUS purchase is therefore zeroForOne.
        if (
            !key.currency0.isAddressZero()
                || Currency.unwrap(key.currency1) != stuusToken
                || address(key.hooks) != address(this)
        ) revert InvalidPool();

        if (params.zeroForOne) {
            int128 amount0 = delta.amount0();
            if (amount0 >= 0) revert InvalidEthDelta();

            uint256 ethSpent = uint256(-int256(amount0));
            if (ethSpent < minimumBuy) revert BuyBelowMinimum(ethSpent, minimumBuy);
        }

        return (this.afterSwap.selector, 0);
    }
}
