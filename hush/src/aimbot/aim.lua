-- src/aimbot/aim.lua — หมุนกล้องไปที่เป้าหมายแบบนุ่มนวล
return function(S, cam, head)
	local goal = CFrame.lookAt(cam.CFrame.Position, head.Position)
	-- Smoothness 1-100: ยิ่งสูงยิ่งล็อกเร็ว (100 = ล็อกทันที)
	local alpha = math.clamp(S.Smoothness, 1, 100) / 100
	cam.CFrame = cam.CFrame:Lerp(goal, alpha)
end
