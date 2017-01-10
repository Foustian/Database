-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClientRole_SelectRoleByClientID] 
	-- Add the parameters for the stored procedure here
	@ClientID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		ClientRoleKey,
		RoleID,
		IsAccess,
		RoleName
	FROM
		ClientRole
	Inner Join Role
		on	
		ClientRole.RoleID = Role.RoleKey
	WHERE
		ClientRole.ClientID=@ClientID and ClientRole.IsAccess = 1
END
