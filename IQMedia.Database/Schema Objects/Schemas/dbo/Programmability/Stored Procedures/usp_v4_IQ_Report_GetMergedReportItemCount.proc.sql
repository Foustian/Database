CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_GetMergedReportItemCount]
	@ReportIDs XML,
	@ItemCount BIGINT OUTPUT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT	@ItemCount = COUNT(DISTINCT Media.ID.value('.', 'bigint'))
			FROM IQMediaGroup.dbo.IQ_Report
			CROSS APPLY ReportRule.nodes('Report/Library/ArchiveMediaSet/ID') as Media(ID)
			WHERE @ReportIDs.exist('list/item[@id=sql:column("IQ_Report.ID")]') = 1
END
