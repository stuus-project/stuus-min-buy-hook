# STUUS Minimum Buy Hook

Public source for the STUUS fixed-supply ERC-20 token and its Ethereum mainnet Uniswap v4 minimum-buy hook.

## Mainnet deployments

- STUUS token: `0x746a2Eb210a72EEE8CCa9Ff2b25F8FC20dFbd7ed`
- Minimum-buy hook: `0x0E14d8EC45656EE16aD3cafcb9dfC6709Fd68040`
- Uniswap v4 PoolManager: `0x000000000004444c5dC75cB358380D2e3dE08A90`
- Pool ID: `0xe9e87c81d86881bd0d8d7f3ff65444196e9bac65f3103b455b93f6663e6aac83`

Pool key:

- currency0: native ETH (`0x0000000000000000000000000000000000000000`)
- currency1: STUUS
- LP fee: `2500` (0.25%)
- tick spacing: `25`
- hook: STUUS Minimum Buy Hook

## Behavior

- The token supply is fixed at 100,000,000,000 STUUS.
- The token has no mint, tax, blacklist, confiscation, or pause function.
- The hook uses only the Uniswap v4 `afterSwap` callback.
- ETH-to-STUUS purchases below the configured minimum revert.
- STUUS-to-ETH sales are not restricted by the hook.
- Adding and removing liquidity are not restricted by the hook.
- The hook does not charge a hook fee or modify swap deltas.
- The hook owner can update the minimum purchase amount. Every update emits `MinimumBuyChanged`.

The initial and current deployment default is `0.005 ETH` unless subsequently changed onchain.

## Build settings

- Solidity: `0.8.26`
- Optimizer: enabled, 200 runs
- EVM version: Cancun

```bash
npm install
npm run compile
```

## Verification

The `verification` directory contains the Standard JSON Input and the deployed constructor arguments used for block-explorer verification.

## Audit status

This repository does not claim that the contracts have received an independent security audit.

## License

MIT
