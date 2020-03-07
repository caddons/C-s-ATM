AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
 
include('shared.lua')
 
function ENT:Initialize()
 
	self:SetModel( "models/props_lab/reciever_cart.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos + Vector( 0, 0, 25 ) )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent

end

util.AddNetworkString( "custom_atm_openmenu" )
function ENT:Use( activator, caller )
	if( IsValid( caller ) ) then
		if( caller:IsPlayer() ) then
			net.Start( "custom_atm_openmenu" )
			net.Send( caller )
		end
	end
end
 
function ENT:Think()

end


util.AddNetworkString( "custom_atm_deposit" )
net.Receive( "custom_atm_deposit", function( len, ply )
	local DepositMoney = net.ReadInt( 32 )

	if( not IsValid( ply ) ) then return end
	if( not DepositMoney ) then return end

	if( isnumber( DepositMoney ) ) then 
		if( DepositMoney > 0 ) then
			if( ply:getDarkRPVar( "money" ) >= DepositMoney ) then
				if( (ply:GetNWInt( "custom_atm_balance", 0 ) + DepositMoney) <= CUSTOM_ATM_CONFIG.MaxStored ) then
					ply:addMoney( -DepositMoney )
					ply:SetNWInt( "custom_atm_balance", ply:GetNWInt( "custom_atm_balance", 0 ) + DepositMoney )
					DarkRP.notify( ply, 1, 3, "You have deposited " .. DarkRP.formatMoney( DepositMoney ) .. " into your bank account!" )
					ply:UpdateATMToFile()
				else
					DarkRP.notify( ply, 1, 3, "You can only store a max of " .. DarkRP.formatMoney( CUSTOM_ATM_CONFIG.MaxStored ) .. " in your bank account!" )
				end
			else
				DarkRP.notify( ply, 1, 3, "You don't have this amount of money to deposit!" )
			end
		else
			DarkRP.notify( ply, 1, 3, "You cannot deposit less than $0!" )
		end
	else
		DarkRP.notify( ply, 1, 3, "The value you entered is not a valid number!" )
	end
end )

util.AddNetworkString( "custom_atm_withdraw" )
net.Receive( "custom_atm_withdraw", function( len, ply )
	local WithdrawMoney = net.ReadInt( 32 )

	if( not IsValid( ply ) ) then return end
	if( not WithdrawMoney ) then return end

	if( isnumber( WithdrawMoney ) ) then 
		if( WithdrawMoney > 0 ) then
			if( ply:GetNWInt( "custom_atm_balance", 0 ) >= WithdrawMoney ) then
				ply:SetNWInt( "custom_atm_balance", ply:GetNWInt( "custom_atm_balance", 0 ) - WithdrawMoney )
				ply:addMoney( WithdrawMoney )
				DarkRP.notify( ply, 1, 3, "You have withdrew " .. DarkRP.formatMoney( WithdrawMoney ) .. " into your bank account!" )
				ply:UpdateATMToFile()
			else
				DarkRP.notify( ply, 1, 3, "You don't have this amount of money to withdraw in your account!" )
			end
		else
			DarkRP.notify( ply, 1, 3, "You cannot withdraw less than $0!" )
		end
	else
		DarkRP.notify( ply, 1, 3, "The value you entered is not a valid number!" )
	end
end )