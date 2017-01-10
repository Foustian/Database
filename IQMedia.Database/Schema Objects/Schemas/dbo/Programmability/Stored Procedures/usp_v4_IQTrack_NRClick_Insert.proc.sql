CREATE PROCEDURE [dbo].[usp_v4_IQTrack_LicenseClick_Insert]
	@CustomerID bigint,
	@MOURL		  varchar(500),
	@Event		  varchar(50),
	@IQLicense		tinyint
AS
BEGIN
	INSERT INTO IQTrack_LicenseClick
	(
		_CustomerGUID,
		MOURL,
		[Event],
		DateModified,
		IQLicense
	)
	SELECT
		CustomerGUID,
		@MOURL,
		@Event,
		GETDATE(),
		@IQLicense
	FROM 
		Customer
	Where 
		CustomerKey = @CustomerID
		AND customer.IsActive = 1


END