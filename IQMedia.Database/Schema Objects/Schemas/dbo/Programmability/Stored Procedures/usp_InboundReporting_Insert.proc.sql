-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_InboundReporting_Insert
	
	@InboundReportingKey	bigint out,
	@RequestCollection		xml
AS
BEGIN

	INSERT INTO [InboundReporting]
           (
				[RequestCollection]
			)
     VALUES
           (
				@RequestCollection
			)
	
	SET @InboundReportingKey = SCOPE_IDENTITY()

END
