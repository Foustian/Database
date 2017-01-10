CREATE PROCEDURE [dbo].[usp_MentionReport_SelectReportByID]
	@MentionID bigint
AS
BEGIN
		SELECT
			MentionReport.ReportXml
		FROM
			MentionReport
		Where 
			ID = @MentionID AND
			IsActive = 1
END