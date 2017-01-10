CREATE PROCEDURE [dbo].[usp_v5_IQTwitterSettings_Update]
(
	@UserTrackGUID UNIQUEIDENTIFIER, 
	@TwitterRule XML,
	@AgentName VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   

		UPDATE IQMediaGroup.dbo.IQ_Twitter_Settings
	    SET TwitterRule = @TwitterRule,
			RuleDisplayName = @AgentName + ' User Track Rule',
			Comments = @AgentName + ' User Track Rule',
		    ModifiedDate = GETDATE()
	    WHERE UserTrackGUID = @UserTrackGUID

		DECLARE @TWTSettingsKey BIGINT
		SELECT @TWTSettingsKey = TWTSettingsKey FROM IQMediaGroup.dbo.IQ_Twitter_Settings WHERE UserTrackGUID = @UserTrackGUID

		INSERT INTO IQMediaGroup.dbo.IQ_Twitter_Settings_History (
			_TWTSettingsKey,
			TwitterRule,
			CreatedDate
		)
		VALUES (
			@TWTSettingsKey,
			@TwitterRule,
			GETDATE()
		)

		SELECT 1
		COMMIT TRANSACTION		
	END TRY
	BEGIN CATCH		
		SELECT -1
		ROLLBACK TRANSACTION
	END CATCH
END
