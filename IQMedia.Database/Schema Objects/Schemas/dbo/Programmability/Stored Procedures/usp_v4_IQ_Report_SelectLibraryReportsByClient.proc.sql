-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27 June 2013
-- Description:	Select all reports by ClientGUID
-- =============================================

CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SelectLibraryReportsByClient]
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ReportTypeID AS BIGINT
	
	SELECT @ReportTypeID = ID FROM IQMediaGroup.dbo.IQ_ReportType WHERE [Identity] = 'v4Library'

	SELECT 
			ID,
			ReportGUID,
			Title,
			ReportRule,
			ReportDate,
			ReportRule.value('count(Report/Library/ArchiveMediaSet/ID)', 'bigint') as RecordCount
	FROM	IQMediaGroup.dbo.IQ_Report
	WHERE	ClientGuid = @ClientGuid
	AND		IsActive = 1
	AND		_ReportTypeID = @ReportTypeID
	
	ORDER BY Title

END
