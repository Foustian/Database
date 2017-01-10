-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQExportService_CheckClipStatusForDownload]
	@ClipGUID uniqueidentifier,
	@Ext	varchar(4)
AS
BEGIN	
	SET NOCOUNT ON;
	
	
	
	IF(EXISTS(SELECT * 
					FROM
						IQService_Export
					Where
						ClipGuid  = @ClipGUID and
						OutputExt = @Ext
						and (Status = 'QUEUED' OR Status = 'IN_PROGRESS')
					)
		 
		)
	BEGIN
			Select 'True'
	END

	ELSE IF(EXISTS(SELECT * 
					FROM
						IQRemoteService_Export
					Where
						ClipGuid  = @ClipGUID and 
						OutputExt=@Ext
						and (Status = 'QUEUED' OR Status = 'IN_PROGRESS')
					)
			)
	BEGIN		
			Select 'True'			
	END
	
ELSE
	BEGIN	
			Select 'False'			
	END 
	

/*IF(
		((Select Status from IQService_Export
			Where ClipGuid  = @ClipGUID) = 'QUEUED')
		 OR
		((Select Status from IQService_Export
			Where ClipGuid  = @ClipGUID) = 'IN_Progress')
	)
	BEGIN
			Select 1

	END

	ELSE IF(
		((Select Status from IQRemoteService_Export
			Where ClipGuid  = @ClipGUID) = 'QUEUED')
		 OR
		((Select Status from IQRemoteService_Export
			Where ClipGuid  = @ClipGUID) = 'IN_Progress') )
	BEGIN
		
			Select 1
			
	END
	
ELSE
	BEGIN
	
			Select 0
			
	END   */


END
