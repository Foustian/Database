-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Select file location from IQCore_ClipMeta table based on ClipDownload IQ_ClipDownload_Key
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQCore_ClipMeta_SelectFileLocationByID] 
	@ID	BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ClipID AS UNIQUEIDENTIFIER

	SELECT @ClipID = ClipID
	FROM	ClipDownload
	WHERE	IQ_ClipDownload_Key = @ID
	AND CustomerGUID = @CustomerGuid
	
    SELECT Value as FileLocation FROM IQCore_ClipMeta WHERE _ClipGuid = @ClipID
    AND	Field IN ('FileLocation','UGCFileLocation')
    
END
