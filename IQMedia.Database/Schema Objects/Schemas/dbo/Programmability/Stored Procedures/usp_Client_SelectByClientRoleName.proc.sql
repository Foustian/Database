
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectByClientRoleName]
	-- Add the parameters for the stored procedure here
	@ClientID	int,
	@RoleName	varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     RoleID
    FROM
        ClientRole
    
    INNER JOIN Role ON ClientRole.RoleID = Role.RoleKey
    WHERE
		ClientID = @ClientID
	AND	Role.RoleName = @RoleName
	And Role.IsActive=1 and ClientRole.IsAccess=1
END


