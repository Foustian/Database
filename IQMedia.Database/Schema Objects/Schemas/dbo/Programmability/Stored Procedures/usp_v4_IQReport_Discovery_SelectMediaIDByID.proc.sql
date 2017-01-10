CREATE PROCEDURE [dbo].[usp_v4_IQReport_Discovery_SelectMediaIDByID]
	@ClientGUID uniqueidentifier,
	@ReportID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select     
		MediaID
	FROM 
		IQReport_Discovery
	WHERE 
		IsActive = 1
	AND
		Status IN ('QUEUED','COMPLETED')
	AND
		ClientGUID = @ClientGUID	
	AND
	ID = @ReportID
END
