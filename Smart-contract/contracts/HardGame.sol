// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "fhevm/lib/TFHE.sol";

contract HardGame{


    euint8[5] SecuredWord;
    euint8[5] GussedWord;
    euint8 public chancesleft;
    ebool isGameEnded;

    constructor(){
    
        euint8 rand1=TFHE.randEuint8();
        euint8 rand2=TFHE.randEuint8();
        euint8 rand3=TFHE.randEuint8();
        euint8 rand4=TFHE.randEuint8();
        euint8 rand5=TFHE.randEuint8();
        


        euint8 first=TFHE.rem(rand1,27);
        euint8 first1=TFHE.rem(rand2,27);
        euint8 first2=TFHE.rem(rand3,27);
        euint8 first3=TFHE.rem(rand4,27);
        euint8 first4=TFHE.rem(rand5,27);

        

       SecuredWord=[first,first1,first2,first3,first4];
        GussedWord=[TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0)];
        chancesleft=TFHE.asEuint8(10);
        isGameEnded=TFHE.asEbool(false);
    }
    function viewanswer(bytes32 pk)public view returns(bytes[5] memory){
        TFHE.optReq(isGameEnded);
        return [TFHE.reencrypt(SecuredWord[0],pk),TFHE.reencrypt(SecuredWord[1],pk),TFHE.reencrypt(SecuredWord[2],pk),TFHE.reencrypt(SecuredWord[3],pk),TFHE.reencrypt(SecuredWord[4],pk)];
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
        euint8 rand1=TFHE.randEuint8();
        euint8 rand2=TFHE.randEuint8();
        euint8 rand3=TFHE.randEuint8();
        euint8 rand4=TFHE.randEuint8();
        euint8 rand5=TFHE.randEuint8();
        


        euint8 first=TFHE.rem(rand1,27);
        euint8 first1=TFHE.rem(rand2,27);
        euint8 first2=TFHE.rem(rand3,27);
        euint8 first3=TFHE.rem(rand4,27);
        euint8 first4=TFHE.rem(rand5,27);

        SecuredWord=[first,first1,first2,first3,first4];
        
        GussedWord=[TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0),TFHE.asEuint8(0)];
        chancesleft=TFHE.asEuint8(10);
        isGameEnded=TFHE.asEbool(false);
        
    }



}