-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerRole_UpdateByClietIDRoleID]
	-- Add the parameters for the stored procedure here
	--@ClientRoleKey int,
	--@IsAccess bit
	@CustomerID int,
	@RoleID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CustomerRoleCount int
    SELECT @CustomerRoleCount = COUNT(*) FROM CustomerRole WHERE CustomerID=@CustomerID AND RoleID=@RoleID
    -- Insert statements for procedure here
    if(@CustomerRoleCount >0)
    begin
	    
		UPDATE
			CustomerRole
		SET
			IsAccess = 0 
		WHERE
			CustomerID = @CustomerID
			and RoleID = @RoleID
			
	end
END
