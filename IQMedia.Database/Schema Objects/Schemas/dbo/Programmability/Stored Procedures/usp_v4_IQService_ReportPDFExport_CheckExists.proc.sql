CREATE PROCEDURE [dbo].[usp_v4_IQService_ReportPDFExport_CheckExists]
	@ReportID BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ReportGUID UNIQUEIDENTIFIER
	SELECT @ReportGUID = ReportGUID FROM IQMediaGroup.dbo.IQ_Report WHERE ID = @ReportID

	SELECT	COUNT(1) AS NumExists
	FROM	IQMediaGroup.dbo.IQService_ReportPDFExport
	WHERE	_ReportGUID = @ReportGUID
			AND Status != 'COMPLETED' 
			AND Status NOT LIKE 'FAILED%'
END