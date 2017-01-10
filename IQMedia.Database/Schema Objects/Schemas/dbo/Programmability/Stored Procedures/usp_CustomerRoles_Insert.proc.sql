-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerRoles_Insert] 
	-- Add the parameters for the stored procedure here
	@CustomerID int,
	@RoleID int,
	@CustomerRoleKey int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
     
     Set @CustomerRoleKey=null
     
    SELECT @CustomerRoleKey = CustomerRoleKey FROM CustomerRole WHERE CustomerID=@CustomerID AND RoleID=@RoleID
    IF @CustomerRoleKey is null 
    BEGIN 
    INSERT INTO	
			CustomerRole
			(
				CustomerID,
				RoleID,
				IsAccess,
				CreatedBy,
				ModifiedBy,
				CreatedDate,
				ModifiedDate
			)
			VALUES
			(
				@CustomerID,
				@RoleID,
				1,
				'System',
				'System',
				SYSDATETIME(),
				SYSDATETIME()
			)
			SELECT @CustomerRoleKey = SCOPE_IDENTITY()
		END
	ELSE
		begin
		
			UPDATE
				CustomerRole
			SET
				IsAccess = 1
			WHERE
				CustomerID = @CustomerID
				and RoleID = @RoleID
			
		end
END
