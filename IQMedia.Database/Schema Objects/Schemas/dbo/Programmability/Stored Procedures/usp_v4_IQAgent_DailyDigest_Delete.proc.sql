CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DailyDigest_Delete]
	@ID bigint
AS
BEGIN
	UPDATE 
			IQAgent_DailyDigest
	SET
			IsActive = 0,
			ModifiedDate = GETDATE()
	WHERE
			ID = @ID
END