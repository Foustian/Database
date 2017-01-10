CREATE PROCEDURE [dbo].[usp_v4_IQArchive_MCMedia_GetReportGUID]
	@MasterClientID BIGINT,
	@ReportGUID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
	SELECT	@ReportGUID = ReportGuid
	FROM	IQMediaGroup.dbo.IQ_Report report WITH (NOLOCK)
	INNER	JOIN IQMediaGroup.dbo.IQ_ReportType reportType ON reportType.ID = report._ReportTypeID
	INNER	JOIN IQMediaGroup.dbo.Client client ON client.ClientGUID = report.ClientGuid
	WHERE	ClientKey = @MasterClientID
			AND reportType.MasterReportType = 'MCMediaTemplate'
END