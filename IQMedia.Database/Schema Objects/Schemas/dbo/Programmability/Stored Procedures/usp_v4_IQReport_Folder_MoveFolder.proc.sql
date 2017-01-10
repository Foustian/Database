CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_MoveFolder]
	@ID bigint,
	@NewParentID bigint,
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @RowsAffected int
	IF NOT EXISTS(SELECT 1 FROM IQReport_Folder where IsActive = 1 and _ParentID = @NewParentID and Name = (SELECT Name From IQReport_Folder Where ID = @ID) AND ID != @ID)
	BEGIN
		UPDATE 
			IQReport_Folder
		SET
			_ParentID = @NewParentID,
			ModifiedDate = GETDATE()
		Where
			ID = @ID
			and _ClientGUID = @ClientGuid
		SET @RowsAffected = @@ROWCOUNT
	END
	ELSE
	BEGIN
		SET @RowsAffected = -1
	END
	SELECT @RowsAffected
		
END