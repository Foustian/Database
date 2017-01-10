CREATE PROCEDURE [dbo].[usp_v4_Customer_UpdatedPassword]
(
	@LoginID	VARCHAR(300),
	@Password	VARCHAR(60)
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			Customer
	SET
			[CustomerPassword] = @Password,
			[PasswordAttempts] = 0,
			[LastPwdChangedDate] = GETDATE()
	WHERE
			[LoginID] = @LoginID	

END