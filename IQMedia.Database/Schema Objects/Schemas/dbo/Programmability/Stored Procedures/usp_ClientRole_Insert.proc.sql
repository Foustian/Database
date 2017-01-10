-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClientRole_Insert] 
	-- Add the parameters for the stored procedure here
	@ClientID int,
	@RoleID int,
	@ClientRoleKey int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     DECLARE @ClientRoleCount int
    SELECT @ClientRoleCount = COUNT(*) FROM ClientRole WHERE ClientID=@ClientID AND RoleID=@RoleID
    IF @ClientRoleCount = 0 
    BEGIN 
    INSERT INTO	
			ClientRole
			(
				ClientID,
				RoleID,
				IsAccess,
				CreatedBy,
				ModifiedBy,
				CreatedDate,
				ModifiedDate
			)
			VALUES
			(
				@ClientID,
				@RoleID,
				1,
				'System',
				'System',
				SYSDATETIME(),
				SYSDATETIME()
			)
			SELECT @ClientRoleKey = SCOPE_IDENTITY()
		END
	ELSE
		begin
		--SET @ClientRoleKey = 0
			UPDATE
				ClientRole
			SET
				IsAccess = 1
			WHERE
				ClientID = @ClientID
				and RoleID = @RoleID
			SET @ClientRoleKey = 0
		end
END
