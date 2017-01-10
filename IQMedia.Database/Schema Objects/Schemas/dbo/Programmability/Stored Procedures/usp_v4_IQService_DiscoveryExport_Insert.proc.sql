CREATE PROCEDURE [dbo].[usp_v4_IQService_DiscoveryExport_Insert]
	@CustomerGuid UNIQUEIDENTIFIER,
	@IsSelectAll BIT,
	@SearchCriteria XML,
	@ArticleXml XML
AS
BEGIN

	DECLARE @Date DATETIME = GETDATE()
	
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @rpID INT
				
		SELECT
				@rpID=IQCore_RootPath.ID
		FROM
				IQCore_RootPath
		WHERE
				IQCore_RootPath.Comment='DiscoveryCSVExport'

		INSERT INTO IQService_DiscoveryExport
		(
			CustomerGuid,
			IsSelectAll,
			SearchCriteria,
			ArticleXml,
			_RootPathID,
			[Status],
			CreatedDate,
			ModifiedDate,
			IsActive
		)

		VALUES
		(
			@CustomerGuid,
			@IsSelectAll,
			@SearchCriteria,
			@ArticleXml,
			@rpID,
			'QUEUED',
			@Date,
			@Date,
			1
		)
		
		DECLARE @DiscoveryExportID INT
		SELECT @DiscoveryExportID = SCOPE_IDENTITY()
		
		INSERT INTO IQJob_Master
		(
		   _RequestID,
		   _TypeID,
		   _CustomerGuid,
		   _Title,
		   _RequestedDateTime,
		   _CompletedDateTime,
		   _DownloadPath,
		  [Status],
		  _RootPathID
		)

		VALUES
		(
			@DiscoveryExportID,
			(SELECT ID FROM IQJob_Type WHERE Name = 'DiscoveryCSVExport'),
			@CustomerGuid,
			NULL,
			@Date,
			NULL,
			NULL,
			'QUEUED',
			@rpID
		)

		SELECT @@ROWCOUNT
	
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
		ROLLBACK TRANSACTION
		
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_IQService_DiscoveryExport_Insert',
				@ModifiedBy='usp_v4_IQService_DiscoveryExport_Insert',
				@CreatedDate=@Date,
				@ModifiedDate=@Date,
				@IsActive=1
				
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		SELECT -1
	END CATCH
	
END