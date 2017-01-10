CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_SuspendRequest]
(
	@ID		BIGINT,
	@ClientGUID		UNIQUEIDENTIFIER,
	@CustomerGUID		UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRANSACTION

	DECLARE @returnCount INT

	UPDATE 
			IQAgent_SearchRequest
	SET
			IsActive=2,
			ModifiedDate=GETDATE(),
			ModifiedBy=@CustomerGUID
	WHERE
			ID=@ID
		AND	ClientGUID=@ClientGUID
		AND IsActive=1

	SET @returnCount=@@ROWCOUNT
	
	-- If Twitter is active, deactivate the appropriate record in IQ_Twitter_Settings
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
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE UserTrackGUID = @GnipTag

		exec usp_v5_IQService_TwitterSettings_Insert @ClientGuid, @CustomerGuid, @ID, 0
	  END

	-- If TVEyes Radio is active, deactivate the appropriate record in IQ_TVEyes_Settings
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
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE TVESettingsKey = @TVESettingsKey

		exec usp_v5_IQService_TVEyesSettings_Insert @ClientGuid, @CustomerGuid, @ID, 0
	  END

	/* Commented out as user can resume agent, and that time need to send notification for the agent.

	CREATE TABLE #TempDelete (NotificationKey BIGINT, TotalCount INT)

	INSERT INTO #TempDelete
	(
		NotificationKey,
		TotalCount
	)
	SELECT 
			IQNotificationSettings.IQNotificationKey,
			IQNotificationSettings.SearchRequestList.value('count(SearchRequestIDList/SearchRequestID)', 'int') TotalNodes
	FROM 
			IQNotificationSettings
				CROSS APPLY IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') AS SEARCH(ids)
	WHERE
			SEARCH.ids.value('.','bigint') = @ID
		AND IQNotificationSettings.ClientGuid = @ClientGuid


	UPDATE
			IQNotificationSettings
	SET
			IsActive = 0
	FROM 
			IQNotificationSettings
				INNER JOIN #TempDelete tmp
					ON IQNotificationSettings.IQNotificationKey = tmp.NotificationKey
					AND tmp.TotalCount = 1
	WHERE IQNotificationSettings.ClientGuid = @ClientGuid
				
	UPDATE
			IQNotificationSettings
	SET
			SearchRequestList.modify('delete /SearchRequestIDList/SearchRequestID[. = sql:variable("@ID")]')
					
	FROM 
			IQNotificationSettings
				INNER JOIN #TempDelete tmp
					ON IQNotificationSettings.IQNotificationKey = tmp.NotificationKey
					AND tmp.TotalCount > 1
	WHERE IQNotificationSettings.ClientGuid = @ClientGuid	

	*/

	COMMIT TRANSACTION

	SELECT @returnCount
	
END
