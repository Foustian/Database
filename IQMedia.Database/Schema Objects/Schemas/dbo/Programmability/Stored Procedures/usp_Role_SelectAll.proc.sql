-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Role_SelectAll] 
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
		RoleKey,
		RoleName,
		IsActive
	FROM
		[Role]
	WHERE
		(@IsActive is null or [Role].IsActive=@IsActive)
	ORDER BY RoleName
		
END
