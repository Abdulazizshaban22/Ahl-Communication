'use client'
import { useEffect, useMemo, useState } from 'react'
import { EditorContent, useEditor } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import Collaboration from '@tiptap/extension-collaboration'
import CollaborationCursor from '@tiptap/extension-collaboration-cursor'
import * as Y from 'yjs'
import { WebsocketProvider } from 'y-websocket'
import { nanoid } from 'nanoid'

const ROOM = 'ahla-notes-default'

export default function Notes(){
  const [status,setStatus] = useState('connecting')
  const ydoc = useMemo(()=> new Y.Doc(), [])
  const provider = useMemo(()=> new WebsocketProvider(process.env.NEXT_PUBLIC_COLLAB_URL||'ws://localhost:1234', ROOM, ydoc), [ydoc])
  useEffect(()=>{ provider.on('status', e=>setStatus(e.status)); return ()=>provider.disconnect() }, [provider])

  const editor = useEditor({
    extensions:[StarterKit, Collaboration.configure({ document: ydoc }), CollaborationCursor.configure({ provider, user: { name: 'You', color: '#0aa' }})],
    content: '<h2>Ahla Notes</h2><p>Start typing…</p>'
  })

  return <main style={{padding:24, maxWidth:800, margin:'0 auto'}}>
    <h1>Ahla Notes</h1>
    <small>Collab: {status}</small>
    <EditorContent editor={editor} />
  </main>
}
