CREATE PROCEDURE [dbo].[usp_v5_IQTVEyesSettings_Delete]
(
	@TVESettingsKey BIGINT
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   
		
		UPDATE IQMediaGroup.dbo.IQ_TVEyes_Settings
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE TVESettingsKey = @TVESettingsKey
		
		SELECT 1
		COMMIT TRANSACTION		
	END TRY
	BEGIN CATCH			
		ROLLBACK TRANSACTION
		SELECT -1
	END CATCH
END