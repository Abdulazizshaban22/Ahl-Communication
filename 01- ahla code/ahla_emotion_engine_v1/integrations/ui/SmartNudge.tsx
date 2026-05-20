import React from 'react'

type Props = {
  suggestions: string[]
  onAccept?: (s: string) => void
  className?: string
}

export const SmartNudge: React.FC<Props> = ({ suggestions, onAccept, className }) => {
  if (!suggestions || suggestions.length === 0) return null
  return (
    <div className={className ?? 'fixed bottom-4 left-1/2 -translate-x-1/2 bg-white border rounded-xl shadow p-3 max-w-lg w-[90%]'}>
      <div className="font-medium mb-2">اقتراح لطيف</div>
      <ul className="space-y-2">
        {suggestions.map((s, i) => (
          <li key={i} className="flex items-start justify-between gap-2">
            <span className="text-sm">{s}</span>
            <button onClick={() => onAccept?.(s)} className="text-xs px-2 py-1 border rounded-md hover:bg-gray-50">استخدم</button>
          </li>
        ))}
      </ul>
    </div>
  )
}
