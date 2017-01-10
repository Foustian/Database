CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_RenameFolder]
	@Name varchar(255),
	@ID bigint,
	@ClientGuid uniqueidentifier
AS
BEGIN
	DECLARE @RowsAffected int
	IF NOT EXISTS(SELECT 1 FROM IQReport_Folder where IsActive = 1 and _ParentID = (SELECT _ParentID FROM IQReport_Folder Where ID  = @ID) and Name = @Name AND ID != @ID)
	BEGIN
		UPDATE 
				IQReport_Folder
		SET
				Name = @Name,
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