CREATE PROCEDURE [dbo].[usp_v5_IQTwitterSettings_Delete]
(
	@UserTrackGUID UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY
		BEGIN TRANSACTION   
		
		UPDATE IQMediaGroup.dbo.IQ_Twitter_Settings
		SET IsActive = 0,
			ModifiedDate = GETDATE()
		WHERE UserTrackGUID = @UserTrackGUID
		
		SELECT 1
		COMMIT TRANSACTION		
	END TRY
	BEGIN CATCH			
		ROLLBACK TRANSACTION
		SELECT -1
	END CATCH
END