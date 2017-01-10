CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_CreateFolder]
	@Name varchar(255),
	@ParentID bigint,
	@ClientGuid uniqueidentifier,
	@Output bigint output
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM IQReport_Folder where IsActive = 1 and _ParentID = @ParentID and Name = @Name)
	BEGIN
		insert into IQReport_Folder
		(
			Name,
			_ClientGUID,
			_ParentID,
			CreatedDate,
			ModifiedDate,
			IsActive
		)

		values
		(
			@Name,
			@ClientGuid,
			@ParentID,
			GETDATE(),
			GETDATE(),
			1
		)	

		SET @Output = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SET @Output = -2;
	END

END