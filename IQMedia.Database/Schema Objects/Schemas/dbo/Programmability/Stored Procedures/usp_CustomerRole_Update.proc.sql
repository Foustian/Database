-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_CustomerRole_Update
	-- Add the parameters for the stored procedure here
	@CustomerRoleKey int,
	@IsAccess bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    UPDATE
		CustomerRole
	SET
		IsAccess = @IsAccess 
	WHERE
		CustomerRoleKey = @CustomerRoleKey
END
