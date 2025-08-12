import React from 'react'
import { createRoot } from 'react-dom/client'

function App(){
  return (
    <div style={{padding:20}}>
      <h1>ERPmac Demo</h1>
      <p>Frontend ishlayapti ✅</p>
    </div>
  )
}

createRoot(document.getElementById('root')).render(<App />)
