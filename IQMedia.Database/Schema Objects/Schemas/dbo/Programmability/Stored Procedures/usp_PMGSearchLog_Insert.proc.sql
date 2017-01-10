-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_PMGSearchLog_Insert] 
	-- Add the parameters for the stored procedure here
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
