-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectAll] 
	-- Add the parameters for the stored procedure here
(
	@IsActive bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		ClientKey,
		ClientName,
		ClientGuid,
		IsActive
	FROM
		Client
	WHERE
		ClientKey !=0 and
		(@IsActive is null or Client.IsActive=@IsActive)
	
	ORDER BY ClientName
	
	SELECT     
		dbo.Client.ClientName, 
		dbo.Client.ClientKey, 
		dbo.ClientRole.RoleID, 
		dbo.Role.RoleName,
		Client.IsActive
	FROM         
		dbo.Role INNER JOIN
        dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID RIGHT OUTER JOIN
		dbo.Client ON dbo.ClientRole.ClientID = dbo.Client.ClientKey
		
	WHERE
		ClientKey !=0 and
		(@IsActive is null or Client.IsActive=@IsActive) and
		--Client.IsActive = 1	
		ClientRole.IsActive = 1 and
		Role.IsActive = 1
	
	ORDER BY ClientName
	
END


