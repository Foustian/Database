CREATE PROCEDURE [dbo].[usp_v4_IQCustomer_RsetPwd_Insert]
(
	@Token	VARCHAR(50),
	@LoginID	VARCHAR(300),
	@DateExpired	DATETIME2
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CustomerGUID	UNIQUEIDENTIFIER

	SELECT
			@CustomerGUID=CustomerGUID
	FROM
			Customer
	WHERE
			CUSTOMER.LoginID = @LoginID
		AND	IsActive = 1

	IF (@CustomerGUID IS NOT NULL)
	BEGIN

		UPDATE
				IQCustomer_RsetPwd
		SET
				IsActive = 0
		WHERE
				_CustomerGUID = @CustomerGUID
			AND IsActive = 1

		INSERT INTO IQCustomer_RsetPwd
		(
			_CustomerGUID,
			Token,
			DateExpired,
			IsActive,
			IsUsed
		)
		VALUES
		(
			@CustomerGUID,
			@Token,
			@DateExpired,
			1,
			0
		)

		SELECT	SCOPE_IDENTITY()		

	END	
	
END