CREATE PROCEDURE [dbo].[usp_v4_PMGSearchLog_Insert]
	@CustomerID				int,
	@SearchType				varchar(50),
	@RequestXML				xml,
	@ErrorResponseXML		xml,
	@PMGSearchLogKey		bigint output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

			INSERT INTO	
			
			PMGSearchLog
			(
				CustomerID,
				SearchType,
				RequestXML,
				ErrorResponseXML
			)
			VALUES
			(
				@CustomerID,
				@SearchType,
				@RequestXML,
				@ErrorResponseXML
			)
			
			SELECT @PMGSearchLogKey = SCOPE_IDENTITY()

END