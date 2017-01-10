-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ClientRole_UpdateByClietIDRoleID]
	-- Add the parameters for the stored procedure here
	--@ClientRoleKey int,
	--@IsAccess bit
	@ClientID int,
	@RoleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ClientRoleCount int
    SELECT @ClientRoleCount = COUNT(*) FROM ClientRole WHERE ClientID=@ClientID AND RoleID=@RoleID
    -- Insert statements for procedure here
    if(@ClientRoleCount >0)
    begin
	    
		UPDATE
			ClientRole
		SET
			IsAccess = 0 
		WHERE
			ClientID = @ClientID
			and RoleID = @RoleID
			
	end
END
