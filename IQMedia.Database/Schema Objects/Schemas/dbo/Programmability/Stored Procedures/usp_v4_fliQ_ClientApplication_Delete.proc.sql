CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_Delete]
	@ID bigint
AS
BEGIN
	UPDATE 
		fliQ_ClientApplication
	SET 
		IsActive = 0 ,
		DateModified = GETDATE()
	WHERE 
		ID = @ID

	SELECT @@ROWCOUNT
END