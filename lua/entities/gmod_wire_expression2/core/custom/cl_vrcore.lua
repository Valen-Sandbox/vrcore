E2Helper.Descriptions["vrSetPlayer"]        = "Sets the player the chip is listening to to the current player; will return 1 if the player is using VR"
E2Helper.Descriptions["vrStopRequesting"]   = "Stops listening to the current player"
E2Helper.Descriptions["vrPlayerInVR"]       = "Returns 1 if a player is in VR"
E2Helper.Descriptions["vrMovement"]         = "Returns the movement of a player (or steering(x,y) if they are driving)"
E2Helper.Descriptions["vrPrimaryFire"]      = "Returns primary fire"
E2Helper.Descriptions["vrPrimary2"]         = "Returns the amount of trigger pull on index"
E2Helper.Descriptions["vrSecondaryFire"]    = "Returns secondary fire"
E2Helper.Descriptions["vrLeftGrab"]         = "Returns 1 if the user has their left hand closed (INDEX ONLY)"
E2Helper.Descriptions["vrRightGrab"]        = "Returns 1 if the user has their right hand closed (INDEX ONLY)"
E2Helper.Descriptions["vrRightHandPos"]     = "Returns local position of the right hand relative to player or vehicle"
E2Helper.Descriptions["vrLeftHandPos"]      = "Returns local position of the left hand relative to player or vehicle"
E2Helper.Descriptions["vrRightHandAng"]     = "Returns local position of the right hand relative to (0,0,0) or vehicle"
E2Helper.Descriptions["vrLeftHandAng"]      = "Returns local position of the left hand relative to (0,0,0) or vehicle"

E2Helper.Descriptions["vrRightHandWorldPos"]     = "Returns local position of the right hand relative to player or vehicle"
E2Helper.Descriptions["vrLeftHandWorldPos"]      = "Returns local position of the left hand relative to player or vehicle"
E2Helper.Descriptions["vrRightHandWorldAng"]     = "Returns local position of the right hand relative to (0,0,0) or vehicle"
E2Helper.Descriptions["vrLeftHandWorldAng"]      = "Returns local position of the left hand relative to (0,0,0) or vehicle"

E2Helper.Descriptions["vrForward"]          = "Returns the forward control in a vehicle"
E2Helper.Descriptions["vrReverse"]          = "Returns the reverse control in a vehicle"
E2Helper.Descriptions["vrTurbo"]            = "Returns the vehicle turbo input"
E2Helper.Descriptions["vrHandbrake"]        = "Returns the vehicle handbrake input"
E2Helper.Descriptions["vrTurret"]           = "Returns the vehicle turbo input"

-- Experimental
E2Helper.Descriptions["vrClientControlsLever"]           = "Creates a new clientside lever from a holo"
E2Helper.Descriptions["vrClientControlsSlider"]           = "Creates a new clientside slider from a holo"
E2Helper.Descriptions["vrClientControlsWheel"]           = "Creates a new clientside wheel from a holo"
E2Helper.Descriptions["vrClientControlsButton"]           = "Creates a new clientside button from a holo"

-- local vrcore_tickrate = CreateConVar("vrcore_net_tickrate", game.SinglePlayer() and "60" or "30", FCVAR_REPLICATED)

local running = false
-- Used since the vehicle movement bindings are tied to the "CreateMove" hook.
local lastTurbo = false
local lastBrake = false
local sentFirstMove = false

net.Receive( "vrcore_activate", function()
    -- Awful fix because calling steamid serverside leads to issues in singleplayer?
    sentFirstMove = false
    local enabled = net.ReadBool()
    local ply = LocalPlayer()

    if not g_VR.net[ply:SteamID()] then return end

    if enabled and not running then
        running = true
        -- We do not attach the input event to a timer on the assumption that the player normally will not press
        -- buttons faster then the timer
        hook.Add( "CreateMove", "vrcore_controller_onvehiclemove", function()
            if not sentFirstMove then
                net.Start( "vrcore_net_firstmove" )
                net.SendToServer()
                sentFirstMove = true
            end

            if ( g_VR.input.boolean_turbo ~= lastTurbo ) or ( g_VR.input.boolean_handbrake ~= lastBrake ) then
                lastTurbo = g_VR.input.boolean_turbo
                lastBrake = g_VR.input.boolean_handbrake
                net.Start( "vrcore_net_vehicle_move" )
                net.WriteBool( g_VR.input.boolean_turbo )
                net.WriteBool( g_VR.input.boolean_handbrake )
                net.SendToServer()
            end
        end )

        hook.Add( "VRUtilEventInput", "vrcore_controller_oninput", function()
            net.Start( "vrcore_net_inputs" )

            if ply:InVehicle() then
                net.WriteBool( g_VR.input.boolean_turret )
            else
                net.WriteBool( g_VR.input.boolean_reload )
                net.WriteBool( g_VR.input.boolean_secondaryfire )
                net.WriteBool( g_VR.input.boolean_primaryfire )
            end

            net.SendToServer()
        end )

        timer.Create( "cl_vrcore_timer_network", 1 / 60, 0,function()
            if not g_VR.net[ply:SteamID()] and running then
                timer.Stop( "vrcore_timer_network" )
                hook.Remove( "CreateMove", "vrcore_controller_onvehiclemove" )
                hook.Remove( "VRUtilEventInput", "vrcore_controller_oninput" )
                running = false
            end

            net.Start( "vrcore_net_timer", true )

            if ply:InVehicle() then
                net.WriteFloat( g_VR.input.vector1_reverse )
                net.WriteVector( Vector( g_VR.input.vector2_steer.x, g_VR.input.vector2_steer.y, g_VR.input.vector1_forward ) )
            else
                net.WriteVector( Vector( g_VR.input.vector2_walkdirection.x, g_VR.input.vector2_walkdirection.y, g_VR.input.vector1_primaryfire ) )
            end

            net.SendToServer()
        end )
    elseif running then
        running = false
        timer.Stop( "cl_vrcore_timer_network" )
        hook.Remove( "CreateMove", "vrcore_controller_onvehiclemove" )
        hook.Remove( "VRUtilEventInput", "vrcore_controller_oninput" )
    end
end)