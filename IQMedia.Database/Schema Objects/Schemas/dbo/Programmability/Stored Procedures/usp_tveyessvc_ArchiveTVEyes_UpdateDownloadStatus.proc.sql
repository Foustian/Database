CREATE PROCEDURE [dbo].[usp_tveyessvc_ArchiveTVEyes_UpdateDownloadStatus]
	@ID bigint,
	@Status varchar(250),
	@MediaUrl varchar(255),
	@PackgeUrl varchar(255)
AS
BEGIN
	
	DECLARE @Output tinyint
	
	UPDATE 
			ArchiveTVEyes
	SET
			[Status] = @Status,
			Media = @MediaUrl,
			Package = @PackgeUrl,
			ModifiedDate = GETDATE()
			
	WHERE
		  ArchiveTVEyesKey = @ID

	Select @@ROWCOUNT as RowAffected
END