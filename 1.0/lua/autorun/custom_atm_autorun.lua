if( SERVER ) then
	local plyMeta = FindMetaTable( "Player" )
	
	function plyMeta:UpdateATMToFile()
		if( not IsValid( self ) ) then return end
		
		if( not file.Exists( "custom_atm", "DATA" ) ) then
			file.CreateDir( "custom_atm" )
		end
		
		local PlyMoney = self:GetNWInt( "custom_atm_balance", 0 )
		file.Write( "custom_atm/" .. self:SteamID64() .. ".txt", PlyMoney )
	end
	
	hook.Add( "PlayerInitialSpawn", "CustomATM_PlayerInitialSpawn_Hook", function( ply )
		if( not IsValid( ply ) ) then return end
		
		if( not file.Exists( "custom_atm", "DATA" ) ) then
			file.CreateDir( "custom_atm" )
		end
		
		if( file.Exists( "custom_atm/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
			local PlyMoney = tonumber( file.Read( "custom_atm/" .. ply:SteamID64() .. ".txt", "DATA" ) )
			if( PlyMoney ) then
				ply:SetNWInt( "custom_atm_balance", PlyMoney )
			end
		end
		
		timer.Create( "custom_atm_interest_timer_" .. ply:SteamID64(), CUSTOM_ATM_CONFIG.InterestTime, 0, function()
			if( IsValid( ply ) ) then
				local NewBalance = math.Clamp( ply:GetNWInt( "custom_atm_balance", 0 )*CUSTOM_ATM_CONFIG.InterestRate, 0, CUSTOM_ATM_CONFIG.MaxStored )
				ply:SetNWInt( "custom_atm_balance", NewBalance )
				ply:UpdateATMToFile()
			else
				timer.Remove( "custom_atm_interest_timer_" .. ply:SteamID64() )
			end
		end )
	end )
end