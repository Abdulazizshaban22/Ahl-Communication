'use client'
import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
export default function Page(){
  const editor = useEditor({ extensions:[StarterKit], content:'<h1>Ahla Book</h1><p>Collaborative docs (wire to collab next)</p>' })
  return <main style={{padding:24}}>
    <h1>Ahla Book</h1>
    <EditorContent editor={editor} />
  </main>
}
