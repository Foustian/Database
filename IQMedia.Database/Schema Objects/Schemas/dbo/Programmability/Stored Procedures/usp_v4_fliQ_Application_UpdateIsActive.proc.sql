CREATE PROCEDURE [dbo].[usp_v4_fliQ_Application_Delete]
	@ApplicationID bigint
AS
BEGIN
	UPDATE 
		fliQ_Application
	SET 
		IsActive = 0 ,
		DateModified = GETDATE()
	WHERE 
		ID = @ApplicationID

	SELECT @@ROWCOUNT
END