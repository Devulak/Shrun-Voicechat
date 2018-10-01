
/*_R = debug.getregistry()

function _R.Player:EV_GetRank()
	if ( !self:IsValid() ) then return false end
	
	local rank
	
	if ( SERVER ) then
		rank = self:GetProperty( "Rank", "guest" )
	else
		rank = self:GetNWString( "EV_UserGroup", "guest" )
	end
	
	if ( evolve.ranks[ rank ] ) then
		return rank
	else
		return "guest"
	end
end*/