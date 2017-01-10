CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_DeleteFolder]
	@ID bigint,
	@ClientGuid uniqueidentifier,
	@Output bigint output
AS
BEGIN
	DECLARE @TempIds TABLE(ID bigint)

	;WITH _tmpParents AS (
		SELECT ID
			FROM IQReport_Folder
				WHERE ID = @ID
				AND _ClientGUID = @ClientGuid
				AND IsActive = 1
			UNION ALL
		SELECT t1.ID
			FROM IQReport_Folder t1 INNER JOIN
				_tmpParents t2 ON t1._ParentID = t2.ID
				AND t1._ClientGUID = @ClientGuid
				AND IsActive = 1
		)

		insert into @TempIds
		SELECT ID from _tmpParents
		

		IF NOT EXISTS(SELECT ID from IQ_Report Where _FolderID in (SELECT ID from @TempIds) ANd IsActive = 1)
		BEGIN
			UPDATE 
				IQReport_Folder
			SET 
				IsActive = 0 
			WHERE
				ID in(SELECT ID FROM @TempIds)

			SET @Output = @@ROWCOUNT
		END
		ELSE 
		BEGIN
			SET @Output = -1
		END
END