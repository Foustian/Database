CREATE PROCEDURE [dbo].[usp_v4_IQCustomer_RsetPwd_UpdatePassword]
(
	@ID	BIGINT,
	@CustomerGUID	UNIQUEIDENTIFIER,
	@Password	VARCHAR(60)
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

		UPDATE
				IQCustomer_RsetPwd
		SET
				IsUsed = 1,
				IsActive = 0
		WHERE
				ID = @ID

		UPDATE
				Customer
		SET
				CustomerPassword = @Password,
				LastPwdRsetDate = GETDATE(),
				RsetPwdEmailCount = 0
		WHERE
				CustomerGUID = @CustomerGUID
			AND	IsActive = 1


	COMMIT TRANSACTION

END