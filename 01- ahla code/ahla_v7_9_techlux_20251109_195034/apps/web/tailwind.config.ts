import type { Config } from "tailwindcss"

export default {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        ahla: {
          green: "#0B7A55",
          beige: "#F7F4EE"
        }
      },
      boxShadow: {
        glass: "0 4px 24px rgba(0,0,0,0.08)"
      },
      backdropBlur: {
        xs: "2px"
      }
    }
  },
  plugins: []
} satisfies Config
