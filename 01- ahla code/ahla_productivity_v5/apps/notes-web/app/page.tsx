'use client'
import { useEffect, useRef, useState } from 'react'
import { EditorContent, useEditor } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import * as Y from 'yjs'
import { WebsocketProvider } from 'y-websocket'

export default function Page(){
  const [status, setStatus] = useState('connecting')
  const ydoc = useRef<Y.Doc>()
  const provider = useRef<WebsocketProvider>()
  const editor = useEditor({ extensions:[StarterKit], content:'<h2>Ahla Notes</h2><p>Start typing…</p>' })

  useEffect(()=>{
    ydoc.current = new Y.Doc()
    provider.current = new WebsocketProvider(process.env.NEXT_PUBLIC_COLLAB_URL || 'ws://localhost:1234', 'notes-demo', ydoc.current)
    provider.current.on('status', e => setStatus(e.status))
    // Simple binding via HTML content (for MVP); real binding would use y-prosemirror
  }, [])

  return <main style={{padding:24}}>
    <h1>Ahla Notes</h1>
    <small>Collab: {status}</small>
    <EditorContent editor={editor} />
  </main>
}
