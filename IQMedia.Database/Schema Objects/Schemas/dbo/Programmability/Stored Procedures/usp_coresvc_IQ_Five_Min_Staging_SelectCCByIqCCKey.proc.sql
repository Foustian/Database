-- =============================================
-- Author:		Sagar Joshi
-- Create date: 03/May/2012
-- Description:	Select IQ_Five_Min_Staging with cc by IQCCKey
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_SelectCCByIqCCKey]
	@IQ_CC_Key varchar(150)
	
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT   
		ISNULL(CONVERT(varchar(10),[last_CCTxt_Segment]),'') as lastCCTxtSegment, 
		ISNULL([current_Active_CCTxt_File],'') as CCTxtFilename , 
		ISNULL([cc_Process_Status],'') as ccStatus,
		ISNULL(CONVERT(varchar(36),[ccTxt_Recordfile_GUID]),'') as recordFileGuid     
	FROM [IQMediaGroup].[dbo].[IQ_Five_Min_Staging]
	Where
	   IQ_CC_Key = @IQ_CC_Key 

	

END
