CREATE PROCEDURE [dbo].[usp_FeedsSearchLog_Insert] 
	@CustomerID				int,
	@SearchType				varchar(50),
	@RequestXML				xml,
	@ErrorResponseXML		xml,
	@FeedsSearchLogKey		bigint output
AS
BEGIN

	INSERT INTO	FeedsSearchLog
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
	
	SELECT @FeedsSearchLogKey = SCOPE_IDENTITY()

END
