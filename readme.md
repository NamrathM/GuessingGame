## Motivation
Traditional word guessing games often store the secret word and player guesses on a central server, raising privacy concerns. This project aims to address these concerns by leveraging homomorphic encryption, allowing players to guess and receive feedback without revealing their inputs or the secret word.

## Technology Stack
- Zama: Provides libraries and tools for fully homomorphic encryption (FHE) on the blockchain.
- TFHE: A homomorphic encryption library used to encrypt and perform computations on the secret word and player guesses.
- Web3: Enables interaction with the blockchain and deployment of the game as a decentralized application.
Key Features
- On-Chain Privacy: Secret word and player guesses are never revealed in plaintext, ensuring complete privacy.
- Two Difficulty Modes: Easy mode offers 5 chances with optional hints, while Hard mode provides 10 chances.
- Decentralized: Game logic and data are stored on the blockchain, eliminating the need for a central server.
- Open-Source: Project code is publicly available, encouraging transparency and community contributions.
Implementation Highlights
- Secret Word Encryption: We leverage TFHE to encrypt the secret word before deploying it to the blockchain. This ensures that no one, including the game developers, can access the word in plaintext.
- Homomorphic Guessing: Players submit their guesses as encrypted values using TFHE. The game logic operates on these encrypted values, comparing them to the encrypted secret word and providing feedback without decrypting any data.
- Concrete Integration: We utilized Concrete to simplify the development process by converting our Python game logic into FHE-compatible code. This significantly reduced development time and complexity.
## Contribution to Zama Bounty Program
This project showcases the potential of Zama's TFHE library and for building privacy-preserving applications on the blockchain. We believe our implementation demonstrates a compelling use case for FHE in the gaming industry and beyond.

## Future Work
- Improve the user interface and gameplay experience.
- Explore the integration of advanced FHE features, such as multi-party computation.
- Implement additional game modes and features.



