# GameLoot

A cross-game NFT platform where in-game items can be used across multiple compatible games in the ecosystem.

## Overview

GameLoot is a Clarity smart contract that enables interoperability of in-game items across different games on the Stacks blockchain. It allows game developers to register their games and define compatibility with NFT items, while players can own and transfer these items between compatible games.

## Features

- **NFT Management**: Mint, transfer, and track ownership of in-game items
- **Game Registration**: Games can register to be part of the GameLoot ecosystem
- **Cross-Game Compatibility**: Define which items work with which games and their power levels
- **Item Attributes**: Store and retrieve metadata and attributes for items
- **Access Controls**: Proper authorization checks for all sensitive operations

## Contract Functions

### Admin Functions

- `set-contract-owner`: Update the contract owner
- `register-game`: Register a new game to the platform
- `deactivate-game`: Deactivate a previously registered game

### NFT Functions

- `mint-item`: Create a new NFT item with metadata
- `transfer-item`: Transfer an item to another user
- `set-item-compatibility`: Define an item's compatibility with a specific game
- `set-item-attributes`: Set or update an item's attributes

### Read-Only Functions

- `get-item-details`: Get basic information about an item
- `get-item-attributes`: Get the attributes of an item
- `get-item-compatibility`: Check if an item is compatible with a specific game
- `get-game-info`: Get information about a registered game
- `get-item-owner`: Get the current owner of an item
- `is-game-active`: Check if a game is currently active

## Usage

### For Game Developers

1. Register your game using `register-game`
2. Define which items are compatible with your game using `set-item-compatibility`
3. Optionally mint new items for your game

### For Players

1. Acquire GameLoot NFT items through minting or transfers
2. Use compatible items across different games in the ecosystem
3. Transfer items to other players as needed

## Development

This contract is developed using Clarity and can be tested with Clarinet.