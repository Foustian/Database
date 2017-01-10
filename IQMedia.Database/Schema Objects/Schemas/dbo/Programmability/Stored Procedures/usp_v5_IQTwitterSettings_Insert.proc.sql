CREATE PROCEDURE [dbo].[usp_v5_IQTwitterSettings_Insert]
(
	@ClientGUID UNIQUEIDENTIFIER,
	@UserTrackGUID UNIQUEIDENTIFIER,
	@AgentName VARCHAR(MAX),
	@TwitterRule XML,
	@SearchRequestID BIGINT
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   

		INSERT INTO IQMediaGroup.dbo.IQ_Twitter_Settings (
			ClientGUID, 
			UserTrackGUID, 
			TwitterRule, 
			RuleDisplayName, 
			Comments, 
			CreatedDate, 
			ModifiedDate, 
			IsActive,
			SRID
		)
		VALUES (
			@ClientGUID, 
			@UserTrackGUID, 
			@TwitterRule, 
			@AgentName + ' User Track Rule', 
			@AgentName + ' User Track Rule', 
			GETDATE(), 
			GETDATE(), 
			1,
			@SearchRequestID
		)

		DECLARE @TWTSettingsKey BIGINT
		SET @TWTSettingsKey = SCOPE_IDENTITY()

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
