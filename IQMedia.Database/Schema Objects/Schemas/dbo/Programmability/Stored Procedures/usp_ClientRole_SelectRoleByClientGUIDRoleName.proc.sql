-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClientRole_SelectRoleByClientGUIDRoleName] 
	-- Add the parameters for the stored procedure here
	@ClientGUID uniqueidentifier,
	@RoleName varchar(150)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		IsAccess
	FROM
		Client 
		inner join 
		ClientRole 
		on
		Client.ClientKey = ClientRole.ClientID
		Inner Join Role
		on	
		ClientRole.RoleID = Role.RoleKey
	WHERE
		Client.ClientGUID=@ClientGUID
		and Role.RoleName =@RoleName
END
