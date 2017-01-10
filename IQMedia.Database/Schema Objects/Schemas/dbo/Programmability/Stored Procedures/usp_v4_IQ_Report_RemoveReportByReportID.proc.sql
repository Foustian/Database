-- =============================================
-- Author:		<Author,,Name>
-- Create date: 24 July 2013
-- Description:	Remove report by reportid
-- =============================================
CREATE PROCEDURE usp_v4_IQ_Report_RemoveReportByReportID
	@ReportID		BIGINT,
	@ClientGuid		UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE IQ_Report
	SET		IsActive = 0
	WHERE	ID = @ReportID
	AND		ClientGuid = @ClientGuid
	
END
GO