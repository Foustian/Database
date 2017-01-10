CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_SearchRequest_ResumeSuspendedRequest]
(
	@ID		BIGINT,
	@ClientGUID		UNIQUEIDENTIFIER,
	@CustomerGUID		UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @returnCount INT=0,
			@Status TINYINT=NULL

	SELECT 
			@Status=IsActive
	FROM 
			IQAgent_SearchRequest 
	WHERE 
			ID=@ID 
		AND ClientGUID=@ClientGUID
	
	IF(@Status=2)
	BEGIN
		UPDATE 
			IQAgent_SearchRequest
		SET
			IsActive=1,
			ModifiedDate=GETDATE(),
			ModifiedBy=@CustomerGUID
		WHERE
			ID=@ID
		AND	ClientGUID=@ClientGUID
		AND IsActive=2

		SET @returnCount=@@ROWCOUNT	

		-- If Twitter is active, reactivate the appropriate record in IQ_Twitter_Settings
		DECLARE @GnipTag VARCHAR(MAX)
		SELECT	
			@GnipTag = SearchTerm.query('SearchRequest/Twitter/GnipTagList/GnipTag').value('.', 'varchar(max)')
		FROM	
			IQAgent_SearchRequest WITH (NOLOCK)
		WHERE	
			ID = @ID
			AND ClientGUID = @ClientGuid
	
		IF ISNULL(@GnipTag, '') != ''
		  BEGIN
			UPDATE IQ_Twitter_Settings
			SET IsActive = 1,
				ModifiedDate = GETDATE()
			WHERE UserTrackGUID = @GnipTag

			exec usp_v5_IQService_TwitterSettings_Insert @ClientGuid, @CustomerGuid, @ID, 0
		  END

		-- If TVEyes Radio is active, reactivate the appropriate record in IQ_TVEyes_Settings
		DECLARE @TVESettingsKey VARCHAR(MAX)
		SELECT	
			@TVESettingsKey = SearchTerm.query('SearchRequest/TM/TVEyesSettingsKey').value('.', 'bigint')
		FROM	
			IQAgent_SearchRequest WITH (NOLOCK)
		WHERE	
			ID = @ID
			AND ClientGUID = @ClientGuid
	
		IF @TVESettingsKey != 0
		  BEGIN
			UPDATE IQ_TVEyes_Settings
			SET IsActive = 1,
				ModifiedDate = GETDATE()
			WHERE TVESettingsKey = @TVESettingsKey

			exec usp_v5_IQService_TVEyesSettings_Insert @ClientGuid, @CustomerGuid, @ID, 0
		  END
	END

	SELECT @Status AS PreviousIsActive,@returnCount AS AffectedRows
	
	
END
