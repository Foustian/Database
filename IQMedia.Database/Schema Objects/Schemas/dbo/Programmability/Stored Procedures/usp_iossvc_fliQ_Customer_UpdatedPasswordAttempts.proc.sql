CREATE PROCEDURE [dbo].[usp_iossvc_fliQ_Customer_UpdatedPasswordAttempts]
(
	@LoginID	VARCHAR(300),
	@ResetPasswordAttempts	BIT=0
)
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE
			fliQ_Customer
	SET
			PasswordAttempts= CASE WHEN @ResetPasswordAttempts=0 THEN ISNULL(PasswordAttempts,0)+1 ELSE 0 END
	WHERE
			LoginID=@LoginID

END