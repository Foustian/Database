-- =============================================
-- Author:		<Author,,Name>
-- Create date: 19 June 2013
-- Description:	Delete record from ClipDownload
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ClipDownload_Delete]
	@CustomerGUID			UNIQUEIDENTIFIER,
	@ClipDownloadKey		BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE ClipDownload
	SET
		IsActive = 0,
		ModifiedDate = GETDATE()
	WHERE
		IQ_ClipDownload_Key = @ClipDownloadKey
	AND	CustomerGUID = @CustomerGUID

END
