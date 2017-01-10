CREATE PROCEDURE [dbo].[usp_v4_IQReport_Feeds_SelectMediaIDByID]
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
		IQReport_Feeds 
	WHERE 
		IsActive = 1
	AND
		Status IN ('QUEUED','COMPLETED')
	AND
		ClientGUID = @ClientGUID	
	AND
	ID = @ReportID
END
