CREATE PROCEDURE usp_iqsvc_Client_CheckForNielSenDataAccessByClientGUID
	@ClientGUID uniqueidentifier
AS
BEGIN
		SELECT
				cast(isnull(ClientRole.IsAccess,0) as bit) AS NielSenDataAccess
		FROM
				Client
					INNER JOIN ClientRole 
						ON 
							Client.ClientKey = ClientRole.ClientID and
							Client.ClientGUID=@ClientGUID
					INNER JOIN [Role]
						ON 
							ClientRole.RoleID = [Role].RoleKey and
							RoleName = 'NielsenData'	
END