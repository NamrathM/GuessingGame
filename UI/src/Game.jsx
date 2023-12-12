import React from 'react'
import { useEffect, useState } from 'react';
// const ethers = require("ethers");
import {ethers}  from 'ethers';
import abi from './abi.json'
import { createInstance ,initFhevm } from 'fhevmjs';

const Game = ({Type}) => {
    const [address, setaddress] = useState();
    const [word, setWord] = useState([]);
    const [answer,setanswer]=useState('')
    const [contract, setcontract] = useState();
    const [instance, setinstance] = useState();
    const [remaining, setRemaining] = useState(5);
    const [gameOver, setGameOver] = useState(Boolean);
    const [win, setWin] = useState(false);
    const [wait ,setwait]=useState(false);

    console.log(Type);
  
    
    const loadData=async()=>{
      // setWin(true)
      const provider=new ethers.providers.Web3Provider(window.ethereum)
      
      const signer=await provider.getSigner();
      if(provider){
        window.ethereum.on("chainChanged",()=>{
          window.location.reload();
        })
        window.ethereum.on("accountsChanged",()=>{
          window.location.reload();
        })
        await provider.send("eth_requestAccounts",[]);
        const chainId = await window.ethereum.request({ method: 'eth_chainId' });
        if(chainId!='0x1F49'){
          try {
            await window.ethereum.request({
              method: 'wallet_switchEthereumChain',
              params: [{ chainId: '0x1F49'}],
            });

          } catch (switchError) {
            if (switchError.code === 4902) {
            try {
              await window.ethereum.request({
                method: 'wallet_addEthereumChain',
                params: [{ chainId: '0x1F49'}]     
              })
            } catch (addError) {
               console.log(addError);
        }
            }
            console.log("Failed to switch to the network")
          }
        }
      }
      const address=await signer.getAddress()
      setaddress(address);
      let contractaddress;
      if(Type==='Easy'){
         contractaddress='0x5879449395c152191f3cF02A85eC2b85ca76ac1B'
      }else if(Type==='Hard'){
        contractaddress='0xF03d76C8c1CBa083451400f78275F5221f588686'
      }
      const contract=new ethers.Contract(contractaddress,abi,signer)
      setcontract(contract)
      // console.log(contract);
      const {chainId}=await provider.getNetwork()
      const publicKey = await provider.call({
        to: "0x0000000000000000000000000000000000000044",
      });
      await initFhevm();

      const Instance =await createInstance({ chainId, publicKey })
     
      const token=Instance.generateToken({
        name:"Authentication",
        verifyingContract:contractaddress,
      })
      
      setinstance(Instance)
      const TFHEguessedwords=await contract.getGussedWord(token.publicKey)
      const guessedwords= TFHEguessedwords.map((value)=>{
        return Instance.decrypt(contractaddress,value)
      })
      setWord(guessedwords)
      
      console.log(guessedwords);
      const TFHEremaining=await contract.getchancesleft(token.publicKey);
      const TFHEGameover=await contract.getisGameEnded(token.publicKey);

      setRemaining( Instance.decrypt(contractaddress,TFHEremaining));
      setGameOver(Boolean( Instance.decrypt(contractaddress,TFHEGameover)));

      setWin(gameOver&&remaining!=0)
      if(gameOver){
        const TFHEanswer=await contract.viewanswer(token.publicKey);
        const Answer =TFHEanswer.map((val)=>{
          return String.fromCharCode(96 + Instance.decrypt(contractaddress,val))
        })
        console.log(Answer);
        setanswer(Answer);
        console.log(typeof answer);
      }

      // const remaining=await instance.decrypt(contractaddress,TFHEremaining)
      // console.log(remaining);
      
    }
    
    useEffect(() => {
      loadData();
      // resetGame();
    }, []);
  
    const resetGame =async () => {
      setwait(true)
     const tx=await contract.resetgame();
     await tx.wait() 
     loadData();
     setwait(false)
    };
    
  
    
  
    const handleGuess =async (letter) => {
      setwait(true)
      const TFHEletter=instance.encrypt8(letter);
      const tx=await contract.Guess(TFHEletter);
      await tx.wait();
      
      loadData();
      setwait(false)
    };
  

    async function toggleHint() {
      const whitelisted=await contract.whitelist(address)
      if(whitelisted){
        var hint = document.getElementById("hintText");
      hint.style.display = (hint.style.display === "none" || hint.style.display === "") ? "block" : "none";
      }else{
        const tx=await contract.Hint({value:ethers.utils.parseEther('5')});
        await tx.wait();
        toggleHint();
      }
      // hint
    }
    // console.log(gameOver);
  
    return (<>{wait?(<>
     <div class="loading-container">
        <div class="loading-svg">
            {/* <!-- SVG for loading icon --> */}
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#fff">
                <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2" fill="none"/>
            </svg>
        </div>
        <p>Waiting to complete transaction...</p>
    </div></>):(<><div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'flex-start',
      height: '100vh',
      marginTop: '2rem',
  }}>
    {!address ? (
      <h3>Connect to Zama Devnet</h3>
    ) : (
      <>
      <h2 style={{marginLeft: 'auto'}}>Mode:{Type}</h2>

      <h1>Guess a Letters in a 5 letter word </h1>
        <div style={{
            marginBottom: '2rem',
        }}>
          <p style={{
              fontSize: '3rem',
              fontWeight: 'bold',
              letterSpacing: '0.5rem',
              padding: '1rem',
              backgroundColor: '#222',
              borderRadius: '10px',
          }}>{word.map((letter) => letter!=0? String.fromCharCode(96 + letter) : '_').join(' ')}</p>
        </div>

          {/* <div style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'flex-start',
              justifyContent: 'flex-start',
              marginBottom: '2rem',
          }}>
              <h3>Guesses:</h3>
              <p style={{
                  fontSize: '2rem',
                  fontWeight: 'bold',
              }}>{guesses.join(', ')}</p>
          </div> */}
        
        <p style={{
              fontSize: '1.25rem',
              fontWeight: 'bold',
              marginBottom: '2rem',
        }}>Remaining Guesses: {remaining}</p>
        <div style={{
              maxWidth: '600px',
              textAlign: 'center',
        }}>
          {'abcdefghijklmnopqrstuvwxyz'.split('').map((letter,index) => (
            <button 
              key={letter} 
              onClick={() => handleGuess(index+1)} 
              disabled={ gameOver}
              style={{
                  border: '1px solid #ccc',
                  padding: '0.5rem 1rem',
                  borderRadius: '4px',
                  fontSize: '0.8rem',
                  cursor: 'pointer',
                  margin: '0.5rem',
                  minWidth: '40px',
              }}
          >
              {letter}
            </button>
          ))}
        </div>
        {gameOver && (
          <div style={{
              position: "absolute",
              height: "100vh",
              width: "100vw",
              backgroundColor: "rgba(0,0,0,0.5)",
              backdropFilter: "blur(5px)",
              display: "flex",
              justifyContent: "center",
              alignItems: "center",
              zIndex: 100,
              color: "#fff"
          }}>
              <div style={{
                  padding: "2rem",
                  backgroundColor: "#333",
                  borderRadius: "10px",
                  textAlign: "center"
              }}>
                  <h3>{win ? 'Congratulations! You won!' : 'Game Over! \n Correct answer is :'+ answer }</h3>
                  <div style={{
                      display: "flex",
                      flexDirection: "column",
                      justifyContent: "center",
                      alignItems: "center"
                  }}>
                      
                      <button 
                          onClick={resetGame}
                          style={{
                              border: "1px solid #ccc",
                              padding: "0.5rem 1rem",
                              borderRadius: "4px",
                              fontSize: "0.8rem",
                              cursor: "pointer",
                              margin: "0.5rem",
                              width: "100%",
                          }}
                      >Restart Game</button>
                  </div>
              </div>
          </div>
        )}
      </>
      
    )}




{Type==='Easy'&&(<div className="hint-container" onClick={toggleHint}>
<span className="hint-symbol">hint</span>
<div className="hint-text" id="hintText">It is a Country Name</div>
</div>)}
      
  </div>
      </>
    )}</>);
}

export default Game