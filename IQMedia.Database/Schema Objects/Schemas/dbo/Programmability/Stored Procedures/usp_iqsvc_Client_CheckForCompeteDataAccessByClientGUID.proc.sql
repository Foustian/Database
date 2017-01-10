CREATE PROCEDURE [dbo].[usp_iqsvc_Client_CheckForCompeteDataAccessByClientGUID]
	@ClientGUID uniqueidentifier
AS
BEGIN
		SELECT
				cast(isnull(ClientRole.IsAccess,0) as bit) AS CompeteDataAccess
		FROM
				Client
					INNER JOIN ClientRole 
						ON 
							Client.ClientKey = ClientRole.ClientID and
							Client.ClientGUID=@ClientGUID
					INNER JOIN [Role]
						ON 
							ClientRole.RoleID = [Role].RoleKey and
							RoleName = 'CompeteData'	
END