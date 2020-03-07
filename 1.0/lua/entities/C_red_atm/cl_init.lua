include('shared.lua')
 
local X, Y = -124, -466
local W, H = 389, 126
function ENT:Draw()
    self:DrawModel()
	
	if( self:GetPos():Distance( LocalPlayer():GetPos() ) > 500 ) then return end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	//TOP PANEL
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Up(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
	
	cam.Start3D2D(Pos + Ang:Up() * 13, Ang, 0.06)
		surface.SetDrawColor( 255, 0, 0, 50 )
		surface.DrawRect( X, Y, W, H )
		
		draw.SimpleText( "C's ATM", "DermaLarge", X+(W/2), Y+(H/2), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	cam.End3D2D()
end

net.Receive( "custom_atm_openmenu", function()
	if( IsValid( CUSTOMATM_MENU ) ) then 
		CUSTOMATM_MENU:SetVisible( true )
		return
	end

	CUSTOMATM_MENU = vgui.Create( "DFrame" )
	CUSTOMATM_MENU:SetTitle( "C's ATM" )
	CUSTOMATM_MENU:MakePopup()
	CUSTOMATM_MENU:SetSize( ScrW()*0.25, ScrH()*0.25 )
	CUSTOMATM_MENU:Center()
	CUSTOMATM_MENU:SetDraggable( false )
	
	local UserInfo = vgui.Create( "DPanel", CUSTOMATM_MENU )
	UserInfo:Dock( TOP )
	UserInfo:SetTall( CUSTOMATM_MENU:GetTall()*0.4 )
	UserInfo.Paint = function( self, w, h )
		draw.SimpleText( LocalPlayer():Nick(), "DermaLarge", w/2, h*0.25, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( DarkRP.formatMoney( math.Round( LocalPlayer():GetNWInt( "custom_atm_balance", 0 ) ) ), "Trebuchet24", w/2, h*0.5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	
	local WithdrawButton = vgui.Create( "DButton", CUSTOMATM_MENU )
	WithdrawButton:Dock( BOTTOM )
	WithdrawButton:SetTall( CUSTOMATM_MENU:GetTall()*0.2 )
	WithdrawButton:SetText( "Withdraw Money" )
	WithdrawButton.DoClick = function()
		Derma_StringRequest( "ATM Withdraw", "How much would you like to withdraw?", "100",
			function( text ) 
				if( text ) then
					if( isnumber( tonumber( text ) ) ) then
						net.Start( "custom_atm_withdraw" )
							net.WriteInt( tonumber( text ), 32 ) 
						net.SendToServer()
					end
				end
			end,
			function( text ) end,
			"Withdraw", "Cancel"
		 )
	end
	
	local DepositButton = vgui.Create( "DButton", CUSTOMATM_MENU )
	DepositButton:Dock( BOTTOM )
	DepositButton:DockMargin( 0, 0, 0, 5 )
	DepositButton:SetTall( CUSTOMATM_MENU:GetTall()*0.2 )
	DepositButton:SetText( "Deposit Money" )
	DepositButton.DoClick = function()
		Derma_StringRequest( "ATM Deposit", "How much would you like to deposit?", "100",
			function( text ) 
				if( text ) then
					if( isnumber( tonumber( text ) ) ) then
						net.Start( "custom_atm_deposit" )
							net.WriteInt( tonumber( text ), 32 ) 
						net.SendToServer()
					end
				end
			end,
			function( text ) end,
			"Deposit", "Cancel"
		 )
	end
end )
 