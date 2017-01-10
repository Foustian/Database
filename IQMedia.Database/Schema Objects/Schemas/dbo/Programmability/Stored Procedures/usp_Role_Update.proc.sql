-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Role_Update]
	-- Add the parameters for the stored procedure here
	@RoleName varchar(50),
	@RoleKey int,
	@Active bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT off;

    -- Insert statements for procedure here
     DECLARE @RoleCount int
    SELECT @RoleCount = COUNT(*) FROM [Role] WHERE RoleName=@RoleName and [Role].RoleKey!=@RoleKey
    IF @RoleCount = 0 
    BEGIN 
    UPDATE [Role]
    SET
		RoleName=@RoleName,
		IsActive=@Active
	WHERE
		RoleKey=@RoleKey
		END
	ELSE
		SET @RoleKey=0
END
