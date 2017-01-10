-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Roles_SelectByRoleName]
	-- Add the parameters for the stored procedure here
	@RoleName varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
	     RoleKey
    FROM
        dbo.[Role]
    WHERE
		RoleName = @RoleName
END
