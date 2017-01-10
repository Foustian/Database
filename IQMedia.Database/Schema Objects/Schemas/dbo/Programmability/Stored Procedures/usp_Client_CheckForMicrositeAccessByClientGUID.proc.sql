-- =============================================
-- Create date: 24/01/2012
-- Description:	GET DETAIL OF IFRAMEMICROSITE ACCESS BY ClientGUID
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_CheckForMicrositeAccessByClientGUID]
	@ClientGUID uniqueidentifier
AS
BEGIN
	
		
		select 
				cast(isnull(ClientRole.IsAccess,0) as bit)
		from 
				Client 
					inner join ClientRole 
						On Client.ClientKey = ClientRole.ClientID and
							Client.ClientGUID=@ClientGUID
					Inner join [Role]
						On ClientRole.RoleID = [Role].RoleKey and
							RoleName = 'IframeMicrosite'	
					
		
END
