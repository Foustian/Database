CREATE PROCEDURE [dbo].[usp_v4_fliQ_CustomerApplication_Delete]
	@ID bigint
AS
BEGIN
	UPDATE
			fliQ_CustomerApplication 
	SET
			IsActive = 0,
			DateModified = GETDATE()
	WHERE
			fliQ_CustomerApplication.ID = @ID

END