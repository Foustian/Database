-- =============================================
-- Author:		<Author,,Name>
-- Create date: 27 June 2013
-- Description:	Insert Report
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_InsertForIQArchive_Media]
	@ReportTitle		VARCHAR(500),
	@ReportRule			XML,
	@ClientGuid			UNIQUEIDENTIFIER,
	@ReportImageID		bigint,
	@ReportID			BIGINT OUTPUT,
	@_FolderID			BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
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
						IsActive,
						_FolderID
					)
					VALUES
					(
						NEWID(),
						@ReportTitle,
						@ReportTypeID,
						@ReportRule,
						@ReportImageID,
						GETDATE(),
						@ClientGuid,
						GETDATE(),
						1,
						@_FolderID
					)
					
					SET @ReportID = SCOPE_IDENTITY()
					
				END
			ELSE
				BEGIN
					SET @ReportID = -1
				END
		END
	ELSE
		BEGIN
			SET @ReportID = 0
		END
END
