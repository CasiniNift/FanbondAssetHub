# FanBond Asset Hub Project

## Overview

This project implements a FanBond smart contract system designed for deployment on the Asset Hub Westend Testnet. It includes two main contracts: Fanbond and FanbondWithReferral, along with a simplified SimpleStorage contract for testing purposes.

## Smart Contracts

### Fanbond.sol

This contract implements the basic functionality of a FanBond system. It allows users to create and manage fan bonds.

### FanbondWithReferral.sol

This contract extends the Fanbond contract to include a referral system.

### SimpleStorage.sol

A simple contract used for testing deployment on the Asset Hub Westend Testnet.

## Deployment

To deploy the contracts to the Asset Hub Westend Testnet:

1. Set up your `.env` file with your private key:
   PRIVATE_KEY=your_private_key_here

2. Update the `hardhat.config.ts` file with the correct network configuration.

   - Network name - Asset-Hub Westend Testnet
   - RPC URL - https://westend-asset-hub-eth-rpc.polkadot.io
   - Chain ID - 420420421
   - Currency symbol - WND
   - Block explorer URL - https://assethub-westend.subscan.io

3. Run the deployment script:
   npx hardhat run scripts/deploy.ts --network assetHubWestend

## Current Limitations and Known Issues

As of the latest attempt, deployment to the Asset Hub Westend Testnet is not successful due to compatibility issues. The following error is encountered:
ProviderError: Failed to instantiate contract: Module(ModuleError { index: 60, error: [26, 0, 0, 0], message: Some("CodeRejected") })

This error suggests that the Asset Hub Westend Testnet may not fully support Ethereum-style smart contracts in its current state.
