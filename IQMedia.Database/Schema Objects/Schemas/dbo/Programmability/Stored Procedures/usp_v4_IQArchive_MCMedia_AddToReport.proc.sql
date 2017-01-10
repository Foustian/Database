CREATE PROCEDURE [dbo].[usp_v4_IQArchive_MCMedia_AddToReport]
	@ReportGUID UNIQUEIDENTIFIER,
	@MasterClientID BIGINT,
	@MediaIDXml XML,
	@ReportTypeID INT,
	@ReturnValue UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @MasterClientGUID UNIQUEIDENTIFIER
		SELECT @MasterClientGUID = ClientGUID FROM Client WHERE ClientKey = @MasterClientID

		IF @ReportGUID IS NULL
		  BEGIN
			SELECT	@ReportGUID = ReportGUID
			FROM	IQ_Report WITH (NOLOCK)
			WHERE	ClientGUID = @MasterClientGUID
					AND EXISTS (SELECT	NULL
								FROM	IQ_ReportType
								WHERE	MasterReportType = 'MCMediaTemplate'
										AND IQ_ReportType.ID = IQ_Report._ReportTypeID)
		  END
		  
		-- If a report doesn't exist for the client, add one
		IF @ReportGUID IS NULL
		  BEGIN
			DECLARE @ClientName VARCHAR(100)

			SELECT	@ClientName = ClientName
			FROM	Client
			WHERE	ClientGUID = @MasterClientGUID

			SET @ReturnValue = NEWID()
		
			INSERT INTO IQ_Report (ReportGUID, Title, _ReportTypeID, ReportRule, ClientGuid, ReportDate, DateCreated, IsActive)
			VALUES (@ReturnValue, 'Published Media For ' + @ClientName, @ReportTypeID, @MediaIDXml, @MasterClientGUID, GETDATE(), GETDATE(), 1)
		  END
		ELSE
		  BEGIN
			DECLARE @CurrentReportRule XML
			DECLARE @UpdatedReportRule XML

			SELECT	@CurrentReportRule = ReportRule
			FROM	IQ_Report WITH (NOLOCK)
			WHERE	ReportGUID = @ReportGUID

			-- Merge existing IDs with new IDs, removing any duplicates
			SELECT	@UpdatedReportRule = 
						(SELECT ISNULL(Added.ID.query('.'), Curr.ID.query('.'))
						 FROM	@CurrentReportRule.nodes('/MediaResults/ID') as Curr(ID)
						 FULL	OUTER JOIN @MediaIDXml.nodes('/MediaResults/ID') as Added(ID)
							ON Curr.ID.value('.', 'bigint') = Added.ID.value('.', 'bigint')
						 FOR XML PATH(''), ROOT('MediaResults'))

			UPDATE IQ_Report
			SET	ReportRule = @UpdatedReportRule,
				ReportDate = GETDATE()
			WHERE ReportGuid = @ReportGUID

			SET @ReturnValue = @ReportGUID
		  END

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
				@CreatedBy='usp_v4_IQArchive_MCMedia_AddToReport',
				@ModifiedBy='usp_v4_IQArchive_MCMedia_AddToReport',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
						
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT		
	END CATCH

END