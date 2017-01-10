-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24 July 2013
-- Description:	append additional items into report
-- =============================================
CREATE PROCEDURE usp_v4_IQ_Report_AppendItemsByReportID
	@ClientGuid		UNIQUEIDENTIFIER,
	@ReportID		BIGINT,
	@AppendItems	XML,
	@SuccessCount	INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ExistingXML AS XML
	DECLARE @ExistingIDs AS TABLE(ID BIGINT)
	DECLARE @NewIDs AS TABLE(RowID INT IDENTITY(1,1),ID BIGINT)
	
	SELECT @ExistingXML = ReportRule FROM IQ_Report WHERE ID = @ReportID AND IsActive = 1
	
	IF @ExistingXML IS NOT NULL 
		BEGIN
			
			SET @SuccessCount = 0
			
			INSERT INTO @ExistingIDs ( ID )
			SELECT tbl.c.query('.').value('.','BIGINT') FROM @ExistingXML.nodes('Report/Library/ArchiveMediaSet/ID') AS tbl(c)
			
			INSERT INTO @NewIDs ( ID )
			SELECT tbl.c.query('.').value('.','BIGINT') FROM @AppendItems.nodes('ID') AS tbl(c)
			
			DECLARE @TotalCount AS INT,@Count AS INT,@TempID AS BIGINT
			
			SET @Count = 1
			SET @TotalCount = (SELECT COUNT(*) FROM @NewIDs)
			
			WHILE @Count <= @TotalCount
				BEGIN
				
					SET @TempID = NULL
					SELECT @TempID = ID FROM @NewIDs WHERE RowID = @Count
					IF NOT EXISTS ( SELECT 1 FROM @ExistingIDs WHERE @TempID IS NOT NULL AND ID = @TempID)
						BEGIN
							SET @ExistingXML.modify('insert <ID>{ sql:variable("@TempID") }</ID> into (/Report/Library/ArchiveMediaSet)[1]')
							SET @SuccessCount = @SuccessCount + 1
						END
					SET @Count = @Count + 1
				END
			
			IF @SuccessCount > 0
				BEGIN
					UPDATE IQ_Report SET ReportRule = @ExistingXML WHERE ID = @ReportID AND IsActive = 1 AND IQ_Report.ClientGuid = @ClientGuid
				END
				
		END
	ELSe
		BEGIN
			SET @SuccessCount = 0
		END

END
GO