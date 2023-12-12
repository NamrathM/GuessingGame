// import logo from './logo.svg';
import { useState } from 'react';
import './App.css';

import Game from './Game';

function App() {
  const [Type,setType]=useState('')

  return (<>{Type===''?(<>
  <h1 style={{color:'black',marginTop:'-30vh',position:'relative'}}>Zama Guessing Game</h1>
  
  <button style={{width:'20vw', display:'flex',margin:'5vh'}} onClick={()=>setType('Easy')}>Easy</button>
            <button style={{width:'20vw', display:'flex',margin:'5vh' }} onClick={()=>setType('Hard')}>Hard</button></>):(<Game Type={Type}/>)
    
  }
  
  {/* {Type==='Easy'&&
    <Game Type={Type}/>}
  {Type==='Hard'&&
    <Game />} */}
  
  {/* <Game/> */}
  </>)
  };

export default App;
