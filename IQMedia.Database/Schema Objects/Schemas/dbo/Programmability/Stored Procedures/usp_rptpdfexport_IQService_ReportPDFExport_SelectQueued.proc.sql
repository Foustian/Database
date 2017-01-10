CREATE PROCEDURE [dbo].[usp_rptpdfexport_IQService_ReportPDFExport_SelectQueued]
(
	 @TopRows INT,  
	 @MachineName VARCHAR(255)  
)
AS
BEGIN

	SET NOCOUNT ON;
	
	;WITH TempReportExport AS  
	 (  
		SELECT TOP(@TopRows)  
				ID
		FROM  
				IQMediaGroup.dbo.IQService_ReportPDFExport
		WHERE   
				[Status] = 'QUEUED'  
		ORDER BY  
				ModifiedDate DESC
	 )  
  
	UPDATE   
		IQMediaGroup.dbo.IQService_ReportPDFExport
	SET  
		[Status] = 'SELECT',  
		MachineName = @MachineName,  
		ModifiedDate=GETDATE()  
	FROM   
		IQMediaGroup.dbo.IQService_ReportPDFExport
			INNER JOIN TempReportExport
				ON IQService_ReportPDFExport.ID = TempReportExport.ID
				AND IQService_ReportPDFExport.[Status] = 'QUEUED'  
  
	 SELECT   
		IQService_ReportPDFExport.ID,  
		CustomerGUID,
		BaseUrl,
		_RootPathID,
		CreatedDate,
		HTMLFilename,
		Title
	 FROM  
		IQMediaGroup.dbo.IQService_ReportPDFExport
	 INNER JOIN
		IQMediaGroup.dbo.IQ_Report 
			ON IQ_Report.ReportGUID = IQService_ReportPDFExport._ReportGUID
	 WHERE  
		[Status] = 'SELECT'  
		AND MachineName = @MachineName  

END