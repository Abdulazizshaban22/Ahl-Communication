import React from 'react';
export const Button: React.FC<React.ButtonHTMLAttributes<HTMLButtonElement>> = ({children,...p}) => (
  <button {...p} style={{padding:'8px 14px', borderRadius:8, border:'1px solid #ccc'}}>{children}</button>
);