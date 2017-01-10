-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12 June 2013
-- Description:	Insert into ArticleNMDownload
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleNMDownload_Insert]
	@CustomerGUID	UNIQUEIDENTIFIER,
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ArticleID VARCHAR(50),
			@DownloadStatus INT,
			@ClientGUID UNIQUEIDENTIFIER

	SELECT
			@ClientGUID=ClientGUID
	FROM
			Client
				INNER JOIN Customer
					ON		Client.ClientKey=Customer.ClientID
						AND Customer.CustomerGUID=@CustomerGUID

	SELECT 
			@ArticleID = ArticleID
	FROM	
			IQArchive_Media
				INNER JOIN ArchiveNM
					ON		IQArchive_Media._ArchiveMediaID = ArchiveNM.ArchiveNMKey
						AND		IQArchive_Media.ID = @ID
						AND		IQArchive_Media.ClientGUID = @ClientGUID
	
    
    IF @ArticleID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ArticleNMDownload WHERE CustomerGUID = @CustomerGUID AND ArticleID = @ArticleID AND DownloadStatus < 2 AND IsActive=1) 
		BEGIN
    
			IF EXISTS(SELECT 1 FROM IQCore_NM WHERE ArticleID = @ArticleID AND [Status] = 'Generated')
				BEGIN
					SET @DownloadStatus = 2
				END
			ELSE
				BEGIN
					SET @DownloadStatus = 1
				END
			
			INSERT INTO ArticleNMDownload
			(
				ARticleID,
				CustomerGuid,
				DownloadStatus,
				DownloadLocation,
				DLRequestDateTime,				
				IsActive
			)
			SELECT 
					@ArticleID,
					@CustomerGUID,
					@DownloadStatus,
					ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_NM.Location,''),
					GETDATE(),					
					1
			FROM	IQCore_NM 
			
			INNER JOIN IQcore_RootPath 
			ON	IQCore_NM._RootPathID = IQcore_RootPath.ID
			AND	IQCore_NM.ArticleID = @ArticleID
			
			WHERE IQCore_NM.ArticleID = @ArticleID
			
		END
END
