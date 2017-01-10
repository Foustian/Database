-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Customer_PasswordReminder
	-- Add the parameters for the stored procedure here
	@Email varchar(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT
		*
	FROM
		Customer
	WHERE
		Customer.Email = @Email
	AND
		Customer.IsActive = 1
END
