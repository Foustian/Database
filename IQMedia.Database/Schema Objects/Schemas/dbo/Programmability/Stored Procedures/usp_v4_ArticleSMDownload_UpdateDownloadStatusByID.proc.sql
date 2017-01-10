-- =============================================
-- Author:		<Author,,Name>
-- Create date: 14 June 2013
-- Description:	Update downloaded file Status
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleSMDownload_UpdateDownloadStatusByID]
	@ID		BIGINT,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE ArticleSMDownload SET DownloadStatus = 3 WHERE ID = @ID AND CustomerGuid = @CustomerGuid

END