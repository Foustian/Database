CREATE PROCEDURE [dbo].[usp_v5_IQService_FeedsExport_Insert]
	@CustomerGuid UNIQUEIDENTIFIER,
	@IsSelectAll BIT,
	@SearchCriteria XML,
	@ArticleXml XML,
	@SortType VARCHAR(20),
	@Title VARCHAR(255),
	@GetTVUrl BIT
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
				IQMediaGroup.dbo.IQCore_RootPath
		WHERE
				IQCore_RootPath.Comment='FeedsCSVExport'

		INSERT INTO IQMediaGroup.dbo.IQService_FeedsExport
		(
			CustomerGuid,
			IsSelectAll,
			SearchCriteria,
			ArticleXml,
			SortType,
			_RootPathID,
			[Status],
			CreatedDate,
			ModifiedDate,
			IsActive,
			Title,
			GetTVUrl
		)
		VALUES
		(
			@CustomerGuid,
			@IsSelectAll,
			@SearchCriteria,
			@ArticleXml,
			@SortType,
			@rpID,
			'QUEUED',
			@Date,
			@Date,
			1,
			@Title,
			@GetTVUrl
		)
		
		DECLARE @FeedsExportID INT
		SELECT @FeedsExportID = SCOPE_IDENTITY()
		
		INSERT INTO IQMediaGroup.dbo.IQJob_Master
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
			@FeedsExportID,
			(SELECT ID FROM IQJob_Type WHERE Name = 'FeedsCSVExport'),
			@CustomerGuid,
			CASE @Title WHEN '' THEN NULL ELSE @Title END, -- Must be null for N/A to display properly on Job Status page
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
				@CreatedBy='usp_v4_IQService_FeedsExport_Insert',
				@ModifiedBy='usp_v4_IQService_FeedsExport_Insert',
				@CreatedDate=@Date,
				@ModifiedDate=@Date,
				@IsActive=1
				
		
		EXEC IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		SELECT -1
	END CATCH
	
END