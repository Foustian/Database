CREATE PROCEDURE [dbo].[usp_v4_IQReport_Discovery_SelectByClientGUID]
	@ClientGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportTypeID AS BIGINT
	
	SELECT @ReportTypeID = ID FROM IQ_ReportType WHERE [Identity] = 'v4Library'

    Select     
		IQReport_Discovery.ID,
		IQReport_Discovery.Title,
		IQReport_Discovery.[Status]
	FROM 
		IQReport_Discovery INNER JOIN IQ_Report
			ON IQReport_Discovery.ReportGUID = IQ_Report.ReportGUID
			AND IQ_Report.ClientGuid =  IQReport_Discovery.ClientGUID 
			AND IQReport_Discovery.IsActive = 1 
			AND IQ_Report.IsActive = 1
			AND IQReport_Discovery.ClientGUID = @ClientGUID
			AND _ReportTypeID = @ReportTypeID
	Order By Title
END