# ModularHub v2 (แยกตามแท็บ/ฟังก์ชัน)

กติกา: โฟลเดอร์ = แท็บ | tab.lua = หน้า UI ของแท็บ | ไฟล์อื่น = ฟังก์ชัน/ฟีเจอร์

src/
  init.lua            จุดเริ่มต้น (ลำดับแท็บอยู่ใน TABS)
  core/               state.lua (ค่าตั้ง) · ui.lua (ไลบรารี GUI) · janitor.lua (ล้างตอน unload)
  main/               tab.lua
  aimbot/             tab · loop · target · visible · aim · autofire
  visuals/            tab · esp · esp_tag · fullbright
  player/             tab · speed · jump
  settings/           tab.lua

รัน:
loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/loader.lua"))()
