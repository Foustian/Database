CREATE PROCEDURE [dbo].[usp_v4_IQService_ReportPDFExport_Insert]
	@ReportID BIGINT,
	@CustomerGuid UNIQUEIDENTIFIER,
	@BaseUrl VARCHAR(250),
	@HTMLFilename VARCHAR(MAX)
AS
BEGIN

	DECLARE @Date DATETIME = GETDATE()
	
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @rpID INT
				
		SELECT
				@rpID = ID
		FROM
				IQMediaGroup.dbo.IQCore_RootPath
		WHERE
				Comment='ReportPDFExport'

		INSERT INTO IQMediaGroup.dbo.IQService_ReportPDFExport
		(
			CustomerGuid,
			BaseUrl,
			_RootPathID,
			[Status],
			CreatedDate,
			ModifiedDate,
			IsActive,
			HTMLFilename,
			_ReportGUID
		)

		VALUES
		(
			@CustomerGuid,
			@BaseUrl,
			@rpID,
			'QUEUED',
			@Date,
			@Date,
			1,
			@HTMLFilename,
			(SELECT ReportGUID FROM IQMediaGroup.dbo.IQ_Report WHERE ID = @ReportID)
		)
		
		DECLARE @ReportPDFExportID INT
		SELECT @ReportPDFExportID = SCOPE_IDENTITY()
		
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
			@ReportPDFExportID,
			(SELECT ID FROM IQMediaGroup.dbo.IQJob_Type WHERE Name = 'ReportPDFExport'),
			@CustomerGuid,
			(SELECT Title FROM IQMediaGroup.dbo.IQ_Report WHERE ID = @ReportID),
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
				
		
		EXEC IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		SELECT -1
	END CATCH
	
END