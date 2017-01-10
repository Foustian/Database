CREATE PROCEDURE [dbo].[usp_iossvc_fliQ_Customer_UpdateUIDNPasswordAttempts]
(
	@CustomerGUID	UNIQUEIDENTIFIER,
	@Application	VARCHAR(155),
	@UID			UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	SET	XACT_ABORT ON;

	BEGIN TRANSACTION

		UPDATE
				[fliQ_CustomerApplication]
		SET
				[UniqueID] = @UID
		FROM
				[fliQ_CustomerApplication]
					INNER JOIN	[fliQ_Application]
						ON	[fliQ_CustomerApplication]._FliqApplicationID=[fliQ_Application].ID
						AND [fliQ_Application].[Application] = @Application
					INNER JOIN	[fliQ_Customer]
						ON	[fliQ_CustomerApplication].[_FliqCustomerGUID] = [fliQ_Customer].[CustomerGUID]
						AND	[fliQ_Customer].CustomerGUID = @CustomerGUID
		WHERE
				[fliQ_Customer].[IsActive] = 1
			AND	[fliQ_Application].[IsActive] = 1
			

		UPDATE
				[fliQ_Customer]
		SET
				[PasswordAttempts] = 0
		WHERE
				[CustomerGUID] = @CustomerGUID
			AND [IsActive] = 1

		COMMIT TRANSACTION

END