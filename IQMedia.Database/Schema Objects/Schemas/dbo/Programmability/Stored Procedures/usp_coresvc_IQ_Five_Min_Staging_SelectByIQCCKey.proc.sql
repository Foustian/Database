-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_SelectByIQCCKey]
	@IQCCKey varchar(150)	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT   
		ISNULL(CONVERT(varchar(10),[Last_Media_Segment]),'') as lastMediaSeg , 
        ISNULL([Current_Active_Media_File],'') as mediaFilename, 
        ISNULL([Media_Process_Status],'') as mediaStatus ,
        ISNULL(CONVERT(varchar(36),[Media_Recordfile_GUID]),'') as recordFileGuid
      FROM 
		[IQ_Five_Min_Staging]
      Where 
		IQ_CC_Key = @IQCCKey 


END