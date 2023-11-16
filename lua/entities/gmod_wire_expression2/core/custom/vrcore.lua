--first time making an e2 extension so I am mostly going off of how AntCore is implemented


E2Lib.RegisterExtension("VRCore", false, "VR functionality")
-- to reduce local var count (max 200 in a script)
-- any would-be locals are instead added to AntCore
local VRCore = {}
VRCore.activePlayers = {}
VRCore.playerData = {}
VRCore.listenerChips = {} --Indexed by chip, contains players
VRCore.playerAlertListeners = {} --Indexed by player, contains an table indexed from the chips listening
VRCore.playerSteamIDs = {}
if SERVER then
	util.AddNetworkString("vrcore_activate")
	util.AddNetworkString("vrcore_net_vehicle_move")
	util.AddNetworkString("vrcore_net_inputs")
	util.AddNetworkString("vrcore_net_timer")
	util.AddNetworkString("vrcore_net_firstmove")
end

function sendActivationMsg(ply,type)
	net.Start( "vrcore_activate" )
	net.WriteEntity(ply)
	net.WriteBool(active)
	net.Broadcast()

end


function stopListening(chip)
	local oldPlayer=VRCore.listenerChips[chip]
	if VRCore.playerAlertListeners[ply] then
		if VRCore.playerAlertListeners[ply][chip]~=nil then
			VRCore.playerAlertListeners[ply][chip]=nil
			local count=0
			for e,_ in pairs( VRCore.playerAlertListeners ) do
				count=count+1
			end
			if count==0 then
				sendActivationMsg(ply,"input",false)
			end
		end
	end
	
end





function VRCore.setup()
    print("VRCore loading")
    timer.Create("sv_vrcore_timer_watchdog", 10, 0,function()
		
		
	end)
end

VRCore.setup()

__e2setcost(5)
e2function number vrSetPlayer(entity ply)
	
	if VRCore.listenerChips[self.entity]~= nil then
		if VRCore.listenerChips[self.entity]==ply then return end
		
		stopListening(self.entity)
		
		
	end
	if VRCore.activePlayers[ply]==1 then
		VRCore.listenerChips[self.entity]=ply
		
		if VRCore.playerAlertListeners[ply]==nil then
			VRCore.playerAlertListeners[ply]={}
		end
		if VRCore.playerAlertListeners[ply][self.entity]==nil then
				VRCore.playerAlertListeners[ply][self.entity]=1
				sendActivationMsg(ply,true)
			
		end
	end
end


__e2setcost(5)
e2function void vrStopRequesting()
	stopListening(self.entity)
	
end

__e2setcost(2)
e2function number vrPlayerInVR(entity ply)
	if VRCore.activePlayers[ply]==1 then
		return 1
	else
		return 0
	end
end



__e2setcost(2)
e2function vector2 vrMovement()
	if VRCore.listenerChips[self.entity]~=nil then
		return {VRCore.playerData[VRCore.listenerChips[self.entity]].steerX,VRCore.playerData[VRCore.listenerChips[self.entity]].steerY}
	else
		return {0,0}
	end
end

__e2setcost(2)
e2function number vrPrimaryFire()
	if VRCore.listenerChips[self.entity]~=nil and VRCore.playerData[VRCore.listenerChips[self.entity]].primaryFire then
		return 1
	else
		return 0
	end
end
__e2setcost(2)
e2function number vrPrimaryFire2()
	
	if VRCore.listenerChips[self.entity]~=nil then
		return VRCore.playerData[VRCore.listenerChips[self.entity]].primaryFire2
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrSecondaryFire()
	if VRCore.listenerChips[self.entity]~=nil and VRCore.playerData[VRCore.listenerChips[self.entity]].secondaryFire then
		return 1
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrLeftGrab()
	
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
	 	if g_VR[steamID].latestFrame~=nil then
			if g_VR[steamID].latestFrame.finger3>0.85 and g_VR[steamID].latestFrame.finger4>0.85 and g_VR[steamID].latestFrame.finger5>0.85 then
				return 1
			end
		end
	end
	
	return 0
	
end

__e2setcost(2)
e2function number vrRightGrab()
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
		if g_VR[steamID].latestFrame~=nil then
			if g_VR[steamID].latestFrame.finger8>0.85 and g_VR[steamID].latestFrame.finger9>0.85 and g_VR[steamID].latestFrame.finger10>0.85 then
				return 1
			end
		end
	end
	return 0
end

__e2setcost(2)
e2function vector vrRightHandPos()
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
		if g_VR[steamID].latestFrame~=nil then
			return g_VR[steamID].latestFrame.righthandPos
		end
	end
		return Vector(0,0,0)
	
end

__e2setcost(2)
e2function vector vrLeftHandPos()
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
		if g_VR[steamID].latestFrame~=nil then
			return g_VR[steamID].latestFrame.lefthandPos
		end
	end
		return Vector(0,0,0)
	
end

__e2setcost(2)
e2function angle vrRightHandAng()
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
		if g_VR[steamID].latestFrame~=nil then
			return g_VR[steamID].latestFrame.righthandAng
		end
	end
		return Angle(0,0,0)
	
end

__e2setcost(2)
e2function angle vrLeftHandAng()
	if VRCore.listenerChips[self.entity]~=nil then
		local steamID=VRCore.listenerChips[self.entity]:SteamID()
		if g_VR[steamID].latestFrame~=nil then
			return g_VR[steamID].latestFrame.lefthandAng
		end
	end
		return Angle(0,0,0)
	
end


__e2setcost(4)
e2function array vrRightHandWorldPosAng()
	if VRCore.listenerChips[self.entity]~=nil then
		local ply=VRCore.listenerChips[self.entity]
		if g_VR[ply:SteamID()].latestFrame~=nil then
			local righthandPos=Vector(0,0,0)
			local righthandAng=Angle(0,0,0)
			local plyAng = ply:GetAngles()
			local plyPos = ply:GetPos()
			local frame=g_VR[ply:SteamID()].latestFrame
			if ply:InVehicle() then
				
				
				righthandPos,righthandAng  = LocalToWorld(frame.righthandPos,frame.righthandAng,plyPos,ply:GetVehicle():LocalToWorldAngles(Angle(0,90,0)))
			else 
				local zeroAngles = Angle()
				righthandPos = LocalToWorld(frame.righthandPos,zeroAngles,plyPos,zeroAngles)
				righthandAng=frame.righthandAng
			end
			
			return {righthandPos,{righthandAng.pitch,righthandAng.yaw,righthandAng.roll}}

		end
	end
		return {Vector(0,0,0),{0,0,0}}
	
end

__e2setcost(4)
e2function array vrLeftHandWorldPosAng()
	if VRCore.listenerChips[self.entity]~=nil then
		local ply=VRCore.listenerChips[self.entity]
		if g_VR[ply:SteamID()].latestFrame~=nil then
			local lefthandPos=Vector(0,0,0)
			local lefthandAng=Angle(0,0,0)
			local plyAng = ply:GetAngles()
			local plyPos = ply:GetPos()
			local frame=g_VR[ply:SteamID()].latestFrame
			if ply:InVehicle() then
				
				
				lefthandPos,lefthandAng  = LocalToWorld(frame.lefthandPos,frame.lefthandAng,plyPos,ply:GetVehicle():LocalToWorldAngles(Angle(0,90,0)))
			else 
				local zeroAngles = Angle()
				lefthandPos = LocalToWorld(frame.lefthandPos,zeroAngles,plyPos,zeroAngles)
				lefthandAng=frame.lefthandAng
			end
			--ply:ChatPrint( tostring(righthandAng) )
			return {lefthandPos,{lefthandAng.pitch,lefthandAng.yaw,lefthandAng.roll}}

		end
	end
		return {Vector(0,0,0),{0,0,0}}
	
end
	





__e2setcost(2)
e2function number vrForward()
	if VRCore.listenerChips[self.entity]~=nil then
		return VRCore.playerData[VRCore.listenerChips[self.entity]].forward
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrReverse()
	if VRCore.listenerChips[self.entity]~=nil then
		return VRCore.playerData[VRCore.listenerChips[self.entity]].reverse
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrTurbo()
	if VRCore.listenerChips[self.entity]~=nil and VRCore.playerData[VRCore.listenerChips[self.entity]].turbo then
		return 1
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrHandbrake()
	if VRCore.listenerChips[self.entity]~=nil and VRCore.playerData[VRCore.listenerChips[self.entity]].handbrake then
		return 1
	else
		return 0
	end
end

__e2setcost(2)
e2function number vrTurret()
	if VRCore.listenerChips[self.entity]~=nil and VRCore.playerData[VRCore.listenerChips[self.entity]].turret then
		return 1
	else
		return 0
	end
end

--[[
__e2setcost(10)
--Assigns a holo as "grabbable", when the player grabs it, their hand will be locked to the position and angle of that holo until they release
--Hand angles are locked to holo angles, returns 1 if successful
e2function number vrCreateGrabPoint(number idx)
	return 0
end

--same as above but allows you to allow the hand to rotate relative to the holo, this can be useful for things like doorknobs where you still want the hand to be able to
--rotate

__e2setcost(10)
e2function number vrCreateGrabPointAngleLock(number idx,angle minAng, angle maxAng)
	return 0
end

__e2setcost(5)
e2function vector vrUserGrabbingHolo(number idx)
	return 0
end

--Returns the hand position just like  vrLeftHandPos() or  vrRightHandPos().
--However it causes the player to send the hand positions more frequently
__e2setcost(20)
e2function vector vrGetHighResGrabData(number idx)
	return 0
end

__e2setcost(10)
e2function vrDestroyGrabPoint(number idx)
	return 0
end
]]


if CLIENT then return end -- No more client
hook.Add("EntityRemoved","vrcore_entityremoved", function(ent)
	
if not IsValid(ent) then return end
	if VRCore.listenerChips[ent] then
		stopListening(ent)
	end
	
end)

hook.Add( "VRUtilStart", "vrcore_player_entered_vr", function(ply)
	VRCore.activePlayers[ply] = 1
	--we fill in some dummey move data so the chips will have somthing to see before the player actualy starts transmitting data
	local tempPlayerData={}
	tempPlayerData.turbo=false
	tempPlayerData.handbrake=false
	tempPlayerData.turret=false
	tempPlayerData.reload=false
	tempPlayerData.primaryFire=false
	tempPlayerData.primaryFire2=false
	tempPlayerData.secondaryFire=false
	tempPlayerData.forward=0
	tempPlayerData.reverse=0
	tempPlayerData.steerX=0
	tempPlayerData.steerY=0
	tempPlayerData.moved=false
	VRCore.playerAlertListeners[ply] = {}
	VRCore.playerData[ply]=tempPlayerData

	
end)
hook.Add( "VRUtilExit", "vrcore_player_left_vr", function(ply)
	VRCore.activePlayers[ply] = nil
	VRCore.playerAlertListeners[ply]=nil
	VRCore.playerData[ply]=nil

	for c,p in pairs(VRCore.listenerChips) do
		if p==ply then
			VRCore.listenerChips[c]=nil
		end
	end
end)
net.Receive("vrcore_net_vehicle_move", function(len, ply)
	VRCore.playerData[ply].turbo=net.ReadBool()
	VRCore.playerData[ply].handbrake=net.ReadBool()
end)

net.Receive("vrcore_net_inputs", function(len, ply)
	if ply:InVehicle() then
		VRCore.playerData[ply].turret=net.ReadBool()
	else
		VRCore.playerData[ply].reload=net.ReadBool()
		VRCore.playerData[ply].secondaryFire=net.ReadBool()
		VRCore.playerData[ply].primaryFire=net.ReadBool()
	end
end)

net.Receive("vrcore_net_firstmove", function(len, ply)
	VRCore.playerData[ply].firstMove=true
end)




net.Receive("vrcore_net_timer", function(len, ply)
	
	
	if VRCore.activePlayers[ply] then
		if ply:InVehicle() then
			VRCore.playerData[ply].reverse=net.ReadFloat()
			local v1=net.ReadVector()
			VRCore.playerData[ply].steerX=v1.x
			VRCore.playerData[ply].steerY=v1.y
			VRCore.playerData[ply].forward=v1.z
		else
			local v1=net.ReadVector()
			VRCore.playerData[ply].steerX=v1.x
			VRCore.playerData[ply].steerY=v1.y
			VRCore.playerData[ply].primaryFire2=v1.z 
		end
	end
	
end)

