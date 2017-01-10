CREATE PROCEDURE [dbo].[usp_v4_IQ_ReportType_Select]
	@MasterReportType VARCHAR(50)
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
	WHERE	IsActive = 1
			AND MasterReportType = @MasterReportType
END