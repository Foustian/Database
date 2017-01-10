-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_Clip_CheckClipByRecordfileGUID]
	@MediaGUID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;
	
	Declare @CoreClipCount bigint
	Declare @ParentClipCount bigint
	Declare @IsClipExists bit

			   Select @CoreClipCount = count(*) 
						FROM 
							IQCore_Clip with (nolock)
						Where 
							_RecordFileGuid = @MediaGUID


			Select @ParentClipCount = Count(*) 
					From 
						IQCore_Clip with (nolock)
						INNER JOIN IQCore_Recordfile with (nolock)
						ON IQCore_Clip._RecordFileGUID = IQCore_Recordfile.GUID						
						Where IQCore_RecordFile._ParentGUID = @MediaGUID					

			--Select @CoreClipCount,@ParentClipCount

			IF(@CoreClipCount > 0 OR @ParentClipCount > 0)
				BEGIN
					Select @IsClipExists = 1		
				END
			ELSE
				BEGIN
					Select @IsClipExists = 0
				END
				
				Select @IsClipExists
END
