export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html>
      <head>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/luckysheet/dist/plugins/css/pluginsCss.css" />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/luckysheet/dist/plugins/plugins.css" />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/luckysheet/dist/css/luckysheet.css" />
        <script src="https://cdn.jsdelivr.net/npm/luckysheet/dist/plugins/js/plugin.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/luckysheet/dist/luckysheet.umd.js"></script>
        <script dangerouslySetInnerHTML={{__html:`
          document.addEventListener('DOMContentLoaded', function(){
            if (window.luckysheet) {
              window.luckysheet.create({ container:'luckysheet', data:[{name:'Sheet1', color:'#ccc'}] });
            }
          });
        `}} />
      </head>
      <body>{children}</body>
    </html>
  )
}
