-- =============================================
-- Author:		<Author,,Name>
-- Create date: 12 June 2013
-- Description:	Insert into ArticleSMDownload
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_ArticleSMDownload_Insert]
	@CustomerGUID	UNIQUEIDENTIFIER,
	@ID				BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ArticleID VARCHAR(50),
			@DownloadStatus INT,
			@ClientGUID	UNIQUEIDENTIFIER

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
				INNER JOIN ArchiveSM
					ON		IQArchive_Media._ArchiveMediaID = ArchiveSM.ArchiveSMKey
						AND		IQArchive_Media.ID = @ID
						AND		IQArchive_Media.ClientGUID = @ClientGUID
	
    
    IF @ArticleID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ArticleSMDownload WHERE CustomerGUID = @CustomerGUID AND ArticleID = @ArticleID AND DownloadStatus < 2 AND IsActive=1) 
		BEGIN
    
			IF EXISTS(SELECT 1 FROM IQCore_SM WHERE ArticleID = @ArticleID AND [Status] = 'Generated')
				BEGIN
					SET @DownloadStatus = 2
				END
			ELSE
				BEGIN
					SET @DownloadStatus = 1
				END
			
			INSERT INTO ArticleSMDownload
			(
				ArticleID,
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
					ISNULL(IQCore_RootPath.StoragePath + '\' + IQCore_SM.Location,''),
					GETDATE(),					
					1
			FROM	IQCore_SM 
			
			INNER JOIN IQcore_RootPath 
			ON	IQCore_SM._RootPathID = IQcore_RootPath.ID
			AND	IQCore_SM.ArticleID = @ArticleID
			
			WHERE IQCore_SM.ArticleID = @ArticleID
			
		END
END
