-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_UpdateCC]
	@IQCCKey varchar(150),
	@RecordFileGuid uniqueidentifier,
	@LastCCTextSegment int,
	@CCTxtFilename varchar(50),
	@CCTxtStatus varchar(150)
AS
BEGIN
	SET NOCOUNT ON;
	
		UPDATE IQMediaGroup.dbo.IQ_Five_Min_Staging
		SET
			[CCTxt_Recordfile_GUID] = @RecordFileGuid,
			[Last_CCTxt_Segment]= @LastCCTextSegment,
			[Current_Active_CCTxt_File]= @CCTxtFilename,
			[CC_Process_Status]= @CCTxtStatus,
			[ModifiedDate]=SYSDATETIME()
		WHERE
			 IQ_CC_key = @IQCCKey 

		Select @@ROWCOUNT 

END
