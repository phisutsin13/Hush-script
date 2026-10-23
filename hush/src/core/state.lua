-- src/core/state.lua — ค่าตั้งเริ่มต้นของทุกฟีเจอร์ (แก้ค่า default ที่นี่)
return {
	Aimbot = {
		Enabled = false, AutoFire = false, Range = 300, Smoothness = 30,
		TeamCheck = true, WallCheck = true, HoldToAim = true, FireRate = 0.1,
	},
	Esp = {Enabled = false, Distance = 500},
	Speed = {Enabled = false, Value = 16},
	Jump = {Enabled = false, Value = 50},
}
