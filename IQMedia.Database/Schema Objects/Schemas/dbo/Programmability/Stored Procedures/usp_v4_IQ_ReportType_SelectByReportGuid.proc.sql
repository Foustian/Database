CREATE PROCEDURE [dbo].[usp_v4_IQ_ReportType_SelectByReportGuid]
	@ReportGuid UNIQUEIDENTIFIER
AS
BEGIN
	SELECT	ID,
			Name,
			[Identity],
			MasterReportType,
			Description,
			Settings,
			IsDefault
	FROM	IQ_ReportType
	WHERE	EXISTS (SELECT	NULL
					FROM	IQ_Report WITH (NOLOCK)
					WHERE	IQ_Report._ReportTypeID = IQ_ReportType.ID
							AND IQ_Report.ReportGUID = @ReportGuid)
END