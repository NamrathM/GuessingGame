## Functions:

**1. constructor()**: 
Initializes the contract by setting the owner address.
Creates a list of 10 pre-defined 5-letter words encrypted with TFHE.
Generates a random number using a keccak256 hash and selects a secret word from the list based on the random value.
Initializes the guessed word, remaining chances, and game end flag with encrypted values.
Adds the owner address to the whitelist for accessing hint functionality.
**1.viewanswer(bytes32 pk)**:
Takes the public key (pk) as input.
Checks if the game is ended (TFHE.optReq).
Re-encrypts each letter of the secret word using the public key and returns the encrypted array.
Hint() public payable:
Requires a payment of 5 ether to access the hint.
Adds the sender address to the whitelist for accessing hint functionality.
Guess(bytes memory _alphabet):
Takes the guessed letter (alphabet) as an encrypted byte string.
Checks if the game is not ended (TFHE.optReq).
Converts the guessed letter to an euint8 value.
Compares the guessed letter with each letter of the secret word using TFHE.eq.
Updates the guessed word array with the correct guess (cmux) and marks the corresponding letter positions in GussedWord.
Decreases the remaining chances by 1 if the guess is incorrect (cmux).
Calls the isEndedcheck function to check if the game should end.
getGussedWord(bytes32 pk):
Takes the public key (pk) as input.
Re-encrypts each letter of the guessed word using the public key and returns the encrypted array.
getchancesleft(bytes32 pk):
Takes the public key (pk) as input.
Re-encrypts the remaining chances using the public key and returns the encrypted value.
getisGameEnded(bytes32 pk):
Takes the public key (pk) as input.
Re-encrypts the game end flag using the public key and returns the encrypted value.
isEndedcheck():
Checks if all letters of the secret word have been correctly guessed (TFHE.and).
Sets the game end flag to true if all letters are guessed or no chances are left (cmux).
resetgame():
Checks if the game is ended (TFHE.optReq).
Generates a new random number using a keccak256 hash and selects a new secret word from the list.
Resets the guessed word, remaining chances, and game end flag with new encrypted values.
Notes:

All sensitive data (secret word, guessed word, chances left) is stored and manipulated using TFHE for homomorphic encryption.
Public functions allow players to submit guesses and view their progress while maintaining privacy.
The Hint function requires a payment to discourage abuse and ensure fair gameplay.
The viewanswer function allows authorized users (whitelisted) to access the secret word after the game ends.
The resetgame function allows players to start a new game after completing or ending the previous one