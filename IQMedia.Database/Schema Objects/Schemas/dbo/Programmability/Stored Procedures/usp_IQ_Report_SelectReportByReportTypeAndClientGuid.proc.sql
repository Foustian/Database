CREATE PROCEDURE [dbo].[usp_IQ_Report_SelectReportByReportTypeAndClientGuid]
	@ClientGuid uniqueidentifier,
	@ReportType bigint,
	@ReportDate datetime
AS
BEGIN
	SELECT 
			IQ_Report.ReportGUID,
			IQ_Report.Title,
			IQ_Report.ReportRule
	FROM
			IQ_Report 
	WHERE
			IQ_Report._ReportTypeID = @ReportType AND
			IQ_Report.ClientGuid = @ClientGuid AND
			CONVERT(Date,IQ_Report.ReportDate) = CONVERT(Date,@ReportDate) AND
			IQ_Report.IsActive = 1 

			
END