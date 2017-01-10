-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_CheckForLimitnData]
	@ClientGuid uniqueidentifier,
	@ReportID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		declare @isFeedsReport bit
		Declare @MaxFeedsReportItems int
		declare @isDiscoveryReport bit
		Declare @MaxDiscoveryReportItems int
		Declare @CurrentReportTotal int

Select @isDiscoveryReport = 
	Case 
		When
			IQReport_Discovery.ID Is Null 
		Then
			0
		Else
			1
	END,
	
	@isFeedsReport = 
	Case 
		When
			IQReport_Feeds.ID Is Null 
		Then
			0
		Else
			1
	END,
	
	@CurrentReportTotal = 
	ReportRule.value('count(/Report/Library/ArchiveMediaSet/ID)', 'int')
	
from 
	IQ_Report
	
	Inner Join IQ_ReportType
	ON IQ_Report._reportTypeID = IQ_ReportType.ID
	AND IQ_ReportType.[Identity] = 'v4Library'
	
	Left Outer join IQReport_Discovery
	On IQ_Report.ReportGuid = IQReport_Discovery.ReportGuid
	
	Left Outer join IQReport_Feeds
	On IQ_Report.ReportGuid = IQReport_Feeds.ReportGuid
	
	
	
	Where IQ_Report.ID = @ReportID 
	
	
	SELECT 
			@MaxFeedsReportItems = Value
		FROM 
			IQClient_CustomSettings 
		WHERE 
			Field = 'v4MaxFeedsReportItems' 
		AND 
		(_ClientGuid = @ClientGuid OR _ClientGuid=CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
		
		SELECT 
			@MaxDiscoveryReportItems = Value
		FROM 
			IQClient_CustomSettings 
		WHERE 
			Field = 'v4MaxDiscoveryReportItems' 
		AND 
		(_ClientGuid = @ClientGuid OR _ClientGuid=CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
		
		
		
		
		Select @isFeedsReport as 'IsFeedsReport',@MaxFeedsReportItems as 'MaxFeedsReportItems',
				@isDiscoveryReport as 'IsDiscoveryReport',@MaxDiscoveryReportItems as 'MaxDiscoveryReportItems',
				@CurrentReportTotal as 'CurrentReportTotal' 
				
END
