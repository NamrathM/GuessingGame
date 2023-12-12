// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "fhevm/lib/TFHE.sol";

contract EasyGame{
    address payable owner;

    euint8[10][10] list;
    euint8[5] SecuredWord;
    euint8[5] GussedWord;
    euint8 public chancesleft;
    ebool isGameEnded;

    mapping (address => bool) public whitelist;

    constructor(){
        owner=payable(msg.sender);

        list[0]=[TFHE.asEuint8(10),TFHE.asEuint8(1),TFHE.asEuint8(16),TFHE.asEuint8(1),TFHE.asEuint8(15)]; //japan
        list[1]=[TFHE.asEuint8(9),TFHE.asEuint8(20),TFHE.asEuint8(1),TFHE.asEuint8(12),TFHE.asEuint8(25)]; //italy
        list[2]=[TFHE.asEuint8(17),TFHE.asEuint8(1),TFHE.asEuint8(20),TFHE.asEuint8(1),TFHE.asEuint8(18)]; //qatar
        list[3]=[TFHE.asEuint8(5),TFHE.asEuint8(7),TFHE.asEuint8(25),TFHE.asEuint8(16),TFHE.asEuint8(20)]; //Egypt
        list[4]=[TFHE.asEuint8(19),TFHE.asEuint8(16),TFHE.asEuint8(1),TFHE.asEuint8(9),TFHE.asEuint8(14)];  //spain
        list[5]=[TFHE.asEuint8(3),TFHE.asEuint8(8),TFHE.asEuint8(9),TFHE.asEuint8(14),TFHE.asEuint8(1)];  //china
        list[6]=[TFHE.asEuint8(9),TFHE.asEuint8(14),TFHE.asEuint8(4),TFHE.asEuint8(9),TFHE.asEuint8(1)];  //india
        list[7]=[TFHE.asEuint8(14),TFHE.asEuint8(5),TFHE.asEuint8(16),TFHE.asEuint8(1),TFHE.asEuint8(12)];  //nepal
        list[8]=[TFHE.asEuint8(25),TFHE.asEuint8(5),TFHE.asEuint8(13),TFHE.asEuint8(5),TFHE.asEuint8(14)];  //yemen
        list[9]=[TFHE.asEuint8(3),TFHE.asEuint8(8),TFHE.asEuint8(9),TFHE.asEuint8(12),TFHE.asEuint8(5)]; //chili


        uint rand=uint256(keccak256(abi.encodePacked(
                tx.origin,
                blockhash(block.number - 1),
                block.timestamp
                )))%5;
        for (uint8 i = 0; i < 5; i++) {
            SecuredWord[i] = list[rand][i];
        }

        
        GussedWord=[TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0)];
        chancesleft=TFHE.asEuint8(5);
        isGameEnded=TFHE.asEbool(false);
    }

    function viewanswer(bytes32 pk)public view returns(bytes[5] memory){
        TFHE.optReq(isGameEnded);
        return [TFHE.reencrypt(SecuredWord[0],pk),TFHE.reencrypt(SecuredWord[1],pk),TFHE.reencrypt(SecuredWord[2],pk),TFHE.reencrypt(SecuredWord[3],pk),TFHE.reencrypt(SecuredWord[4],pk)];

    }

    function Hint()public payable  {
        require(msg.value== 5 ether,"insufficient amount");
        whitelist[msg.sender]=true;
    }




    function Guess(bytes memory _alphabet) public {
        TFHE.optReq(TFHE.not(isGameEnded));
        euint8 alphabet=TFHE.asEuint8(_alphabet);
        ebool correctguess=TFHE.asEbool(false);
        for(uint i=0;i<5;i++){
        ebool isright = TFHE.eq(alphabet,SecuredWord[i]);
        correctguess=TFHE.or(isright,correctguess);
        GussedWord[i]=TFHE.cmux(isright,SecuredWord[i],GussedWord[i]);
        }

        chancesleft=TFHE.cmux(correctguess,chancesleft,TFHE.sub(chancesleft,1));
        isEndedcheck();
    }

    function getGussedWord(bytes32  pk) public view returns(bytes[5] memory){
        return [TFHE.reencrypt(GussedWord[0],pk),TFHE.reencrypt(GussedWord[1],pk),TFHE.reencrypt(GussedWord[2],pk),TFHE.reencrypt(GussedWord[3],pk),TFHE.reencrypt(GussedWord[4],pk)];
    }
    function getchancesleft(bytes32  pk) public view returns(bytes memory){
        return TFHE.reencrypt(chancesleft,pk);
    }
    function getisGameEnded(bytes32 pk) public view returns(bytes memory){
        return TFHE.reencrypt(isGameEnded,pk);
    }
    function isEndedcheck() internal {
        ebool check=TFHE.asEbool(true);
        for(uint8 i=0;i<5;i++){
            check=TFHE.and(check,TFHE.eq(GussedWord[i],SecuredWord[i]));
        }
        isGameEnded=TFHE.cmux(TFHE.eq(chancesleft,0),TFHE.asEbool(true),check);
    }

    function resetgame() public {
        TFHE.optReq(isGameEnded);
        
        uint rand=uint256(keccak256(abi.encodePacked(
                tx.origin,
                blockhash(block.number - 1),
                block.timestamp
                )))%5;
        for (uint8 i = 0; i < 5; i++) {
            SecuredWord[i] = list[rand][i];
        }
        GussedWord=[TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0)];
        chancesleft=TFHE.asEuint8(5);
        isGameEnded=TFHE.asEbool(false);
        
    }


}