-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Role_Insert] 
	-- Add the parameters for the stored procedure here
	@RoleName varchar(50),
	@RoleKey int out
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     DECLARE @RoleCount int
    SELECT @RoleCount = COUNT(*) FROM [Role] WHERE RoleName=@RoleName
    IF @RoleCount = 0 
    BEGIN 
    INSERT INTO 
			[Role] 
			(
				RoleName,
				CreatedDate,
				ModifiedDate,
				IsActive
			)
		VALUES
			(
				@RoleName,
				SYSDATETIME(),
				SYSDATETIME(),
				1
			)
		SELECT @RoleKey = SCOPE_IDENTITY()
    END
	ELSE
		SET @RoleKey=0
END
