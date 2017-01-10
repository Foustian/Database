CREATE PROCEDURE [dbo].[usp_v4_Client_SelectCustomHeaderByReportGuid]
	@ReportGuid uniqueidentifier
AS
BEGIN
	SELECT 
		 Location as CustomHeaderImage
	FROM
		IQClient_CustomImage 
			INNER JOIN Client
				ON Client.ClientGUID = IQClient_CustomImage._ClientGUID
				AND Client.IsActive = 1
				AND IQClient_CustomImage.IsDefault = 1
				AND IQClient_CustomImage.IsActive = 1
			INNER JOIN IQ_Report
				ON IQClient_CustomImage._ClientGUID= IQ_Report.ClientGuid
	WHERE
		IQ_Report.ReportGUID = @ReportGuid
		AND IQ_Report.IsActive = 1
		
		
END