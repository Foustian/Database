
CREATE PROCEDURE [dbo].[usp_ClipDownload_Update]
(
	@XmlData	xml
)
AS
BEGIN
	SET NOCOUNT ON;
	
	update
			ClipDownload
	set
			ClipDownloadStatus=XmlTbl.d.value('@ClipDownloadStatus','tinyint'),
			ClipDLFormat=XmlTbl.d.value('@ClipDLFormat','varchar(50)'),
			ClipFileLocation=XmlTbl.d.value('@ClipFileLocation','varchar(150)'),
			ClipDLRequestDateTime=GETDATE()
			
	From
			@XmlData.nodes('/ClipDownload/Clip') as XmlTbl(d)
	Where
			IQ_ClipDownload_Key=XmlTbl.d.value('@IQ_ClipDownload_Key','bigint')


END
