CREATE PROCEDURE [dbo].[usp_v5_IQTVEyesSettings_Update]
(
	@TVESettingsKey BIGINT, 
	@SearchTerm VARCHAR(MAX),
	@AgentName VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   

		UPDATE IQMediaGroup.dbo.IQ_TVEyes_Settings
	    SET TVESearchTerm = @SearchTerm,
			SearchDisplayName = @AgentName + ' Search Term',
			Comments = @AgentName + ' Search Term',
		    ModifiedDate = GETDATE()
	    WHERE TVESettingsKey = @TVESettingsKey

		INSERT INTO IQMediaGroup.dbo.IQ_TVEyes_Settings_History (
			_TVESettingsKey,
			TVESearchTerm,
			CreatedDate
		)
		VALUES (
			@TVESettingsKey,
			@SearchTerm,
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