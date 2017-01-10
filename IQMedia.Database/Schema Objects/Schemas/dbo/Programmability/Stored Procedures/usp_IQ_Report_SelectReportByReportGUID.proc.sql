CREATE PROCEDURE [dbo].[usp_IQ_Report_SelectReportByReportGUID]
	@ReportGUID uniqueidentifier
AS
BEGIN
		SELECT
			IQ_Report.ID,
			IQ_Report.ReportRule,
			IQ_Report.ClientGuid,
			IQ_Report._ReportTypeID,
			IQ_ReportType.Name,
			IQ_ReportType.[Identity],
			IQ_Report.ReportGUID
		FROM
			IQ_Report INNER JOIN IQ_ReportType
				ON IQ_Report._ReportTypeID = IQ_ReportType.ID
		Where 
			IQ_Report.ReportGUID = @ReportGUID AND
			IQ_Report.IsActive = 1
END