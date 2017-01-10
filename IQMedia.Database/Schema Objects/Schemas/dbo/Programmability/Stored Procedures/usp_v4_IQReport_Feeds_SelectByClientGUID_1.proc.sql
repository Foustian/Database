CREATE PROCEDURE [dbo].[usp_v4_IQReport_Feeds_SelectByClientGUID]
	@ClientGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportTypeID AS BIGINT
	
	SELECT @ReportTypeID = ID FROM IQ_ReportType WHERE [Identity] = 'v4Library'

    Select     
			IQReport_Feeds.ID,
			IQReport_Feeds.Title
	FROM 
			IQReport_Feeds INNER JOIN IQ_Report
				ON IQReport_Feeds.ReportGUID = IQ_Report.ReportGUID
				AND IQReport_Feeds.ClientGUID = IQ_Report.ClientGuid
				AND IQReport_Feeds.IsActive = 1 AND IQ_Report.IsActive = 1
				AND IQReport_Feeds.[Status] = 'COMPLETED'
				AND IQReport_Feeds.ClientGUID = @ClientGUID
				AND _ReportTypeID = @ReportTypeID
	Order By 
			Title
END