CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_MergeReports]
	@ReportTitle VARCHAR(500),
	@ReportImageID BIGINT,
	@FolderID BIGINT,
	@ReportIDs XML,
	@ClientGuid	UNIQUEIDENTIFIER,
	@ReportID BIGINT OUTPUT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF NOT EXISTS(SELECT 1 FROM IQMediaGroup.dbo.IQ_Report WHERE ClientGuid = @ClientGuid AND Title = @ReportTitle AND IsActive = 1)
		BEGIN	
			DECLARE @ReportTypeID BIGINT
			DECLARE @ReportRule XML
			DECLARE @MaxReportItems INT

			SELECT	@MaxReportItems = [Value] 
			FROM	IQClient_CustomSettings 
			WHERE	Field = 'v4MaxLibraryReportItems'
			AND		(_ClientGuid = @ClientGUID OR _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
			order by _ClientGuid asc
	
			SELECT @ReportTypeID = ID FROM IQMediaGroup.dbo.IQ_ReportType WHERE [Identity] = 'v4Library'

			SELECT @ReportRule = 
						(SELECT DISTINCT Media.ID.value('.', 'bigint') as ID
						 FROM IQMediaGroup.dbo.IQ_Report
						 CROSS APPLY ReportRule.nodes('Report/Library/ArchiveMediaSet/ID') as Media(ID)
						 WHERE @ReportIDs.exist('list/item[@id=sql:column("IQ_Report.ID")]') = 1
						 FOR XML PATH(''))

			IF (SELECT @ReportRule.value('count(ID)', 'int')) <= @MaxReportItems
				BEGIN
					SET @ReportRule = '<Report><Library><ArchiveMediaSet>' + CAST(@ReportRule AS NVARCHAR(MAX)) + '</ArchiveMediaSet></Library></Report>'
			
					IF @ReportTypeID > 0
						BEGIN
							INSERT INTO IQMediaGroup.dbo.IQ_Report
							(
								ReportGUID,
								Title,
								_ReportTypeID,
								ReportRule,
								_ReportImageID,
								ReportDate,
								ClientGuid,
								DateCreated,
								IsActive,
								_FolderID
							)
							VALUES
							(
								NEWID(),
								@ReportTitle,
								@ReportTypeID,
								@ReportRule,
								@ReportImageID,
								GETDATE(),
								@ClientGuid,
								GETDATE(),
								1,
								@FolderID
							)
					
							SET @ReportID = SCOPE_IDENTITY()					
						END
					ELSE
						BEGIN
							SET @ReportID = -2
						END
				END
			ELSE
				BEGIN
					SET @ReportID = -1
				END
		END
	ELSE
		BEGIN
			SET @ReportID = 0
		END
END
