CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SaveReportWithSettings]
	@ReportID bigint,
	@ReportSettingsRule xml,
	@ReportImageID	bigint,
	@ClientGuid uniqueidentifier,
	@IsSaveAs	bit,
	@ReportTitle	varchar(255),
	@ResetSort bit,
	@Output bigint output
AS
BEGIN
	DECLARE @ExistingXML AS XML
	DECLARE @ReportRuleWithXml xml
	DECLARE @ReportGUID uniqueidentifier
	SELECT 
		@ExistingXML = ReportRule.query('Report/Library/ArchiveMediaSet'),
		@ReportGUID = ReportGUID
	FROM 
		IQ_Report 
	WHERE 
		ID = @ReportID 
		AND IsActive = 1

	IF @ExistingXML IS NOT NULL 
	BEGIN
		SET @ReportRuleWithXml = '<Report><Library>'+cast(@ExistingXML as varchar(max))+cast(@ReportSettingsRule as varchar(max))+'</Library></Report>'
		IF(@IsSaveAs = 1)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM IQ_Report WHERE ClientGuid = @ClientGuid AND Title = @ReportTitle AND IsActive = 1)
			BEGIN
				DECLARE @ReportTypeID AS BIGINT
				SELECT @ReportTypeID = ID FROM IQ_ReportType WHERE [Identity] = 'v4Library'
				IF @ReportTypeId > 0
				BEGIN

					INSERT INTO IQ_Report
					(
						ReportGUID,
						Title,
						_ReportTypeID,
						ReportRule,
						_ReportImageID,
						ReportDate,
						ClientGuid,
						DateCreated,
						IsActive
					)
					VALUES
					(
						NEWID(),
						@ReportTitle,
						@ReportTypeID,
						@ReportRuleWithXml,
						@ReportImageID,
						GETDATE(),
						@ClientGuid,
						GETDATE(),
						1
					)
					
					SET @Output = SCOPE_IDENTITY()
					
					-- If not resetting custom sorting, copy it from the source report
					IF @ResetSort = 0
					  BEGIN
						DECLARE @NewReportGuid uniqueidentifier
						SELECT @NewReportGuid = ReportGUID from IQ_Report where ID = @Output

						INSERT INTO IQ_Report_ItemPositions (_ReportGUID, _ArchiveMediaID, GroupTier1Value, GroupTier2Value, Position, CreatedDate, ModifiedDate, IsActive)
						SELECT	@NewReportGuid,
								_ArchiveMediaID,
								GroupTier1Value,
								GroupTier2Value,
								Position,
								GETDATE(),
								GETDATE(),
								1
						FROM	IQ_Report_ItemPositions
						WHERE	_ReportGUID = @ReportGUID
								AND IsActive = 1
					  END
				END
			ELSE
				BEGIN
					SET @Output = -2
				END
			END
			ELSE
			BEGIN
				SET @Output = -1
			END
		END
		ELSE
		BEGIN
			UPDATE 
				IQ_Report
			Set
				ReportRule = @ReportRuleWithXml,
				_ReportImageID = @ReportImageID,
				Title = @ReportTitle
			WHERE
				ID = @ReportID
				AND ClientGuid = @ClientGuid
							
			UPDATE
				IQReport_Feeds
			Set
				Title = @ReportTitle
			WHERE
				ReportGUID = @ReportGUID
				
			UPDATE
				IQReport_Discovery
			Set
				Title = @ReportTitle
			WHERE
				ReportGUID = @ReportGUID

			IF @ResetSort = 1
			  BEGIN
				UPDATE IQ_Report_ItemPositions
				SET IsActive = 0,
					ModifiedDate = GETDATE()
				WHERE _ReportGUID = @ReportGUID
			  END

			SET @Output = @ReportID
		END
	END
	ELSE
	BEGIN
		SET @Output = -3
	END
END