-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClientRole_SelectAll]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		ClientRole.ClientRoleKey,
		ClientRole.ClientID,
		ClientRole.RoleID,
		ClientRole.IsAccess,
		Client.ClientName,
		[Role].RoleName
	FROM
		ClientRole
	INNER JOIN
		Client
	ON
		Client.ClientKey = ClientRole.ClientID
	INNER JOIN
		[Role]
	ON
		Role.RoleKey = ClientRole.RoleID
	
END
