-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Check for clip location into IQService_Export && IQRemoteService_Export table 
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQServiceAndIQRemoteService_Export_SelectByClipID]
	@ClipID			UNIQUEIDENTIFIER,
	@ClipExtension	VARCHAR(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @IsFileExists AS BIT
	
	SET @IsFileExists = 0
	
	IF EXISTS(SELECT 1 FROM IQService_Export 
				WHERE ClipGUID = @ClipID AND OutputExt = @ClipExtension
				AND [Status] IN('QUEUED','IN_PROGRESS'))
		BEGIN
			SET @IsFileExists = 1
		END
	
	IF @IsFileExists = 0 AND EXISTS(SELECT 1 FROM IQRemoteService_Export 
									WHERE ClipGUID = @ClipID AND OutputExt = @ClipExtension
									AND [Status] IN('QUEUED','IN_PROGRESS'))
		BEGIN
			SET @IsFileExists = 1
		END
		
	SELECT @IsFileExists
    
END
