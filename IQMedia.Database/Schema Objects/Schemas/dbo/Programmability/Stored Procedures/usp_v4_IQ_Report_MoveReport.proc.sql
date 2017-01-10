CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_MoveReport]
	@ID bigint,
	@NewParentID bigint,
	@ClientGuid uniqueidentifier
AS
BEGIN
	UPDATE 
			IQ_Report
	SET
			_FolderID = @NewParentID,
			ModifiedDate = GETDATE()
	Where
			ID = @ID
			and _ClientGUID = @ClientGuid

	SELECT @@ROWCOUNT	
END