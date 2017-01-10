CREATE PROCEDURE [dbo].[usp_v4_IQReport_Folder_CopyFolder]
	@IDtoCopy bigint,
	@IDtoPaste bigint,
	@ClientGuid uniqueidentifier
AS
BEGIN 
	DECLARE @tblCopy TABLE(AutoID INT IDENTITY(1,1), ID INT, Name VARCHAR(100), ParentID INT)

	DECLARE @OldID INT
	DECLARE @NewID INT

	DECLARE @IdsMapping TABLE(Old_Id int , New_Id int)

	;WITH _tmpParents AS (
		SELECT ID,Name,_ParentID
			FROM IQReport_Folder
				WHERE ID = @IDtoCopy
				AND _ClientGUID = @ClientGuid
			UNION ALL
		SELECT t1.ID,t1.Name,t1._ParentID
			FROM IQReport_Folder t1 INNER JOIN
				_tmpParents t2 ON t1._ParentID = t2.ID
				AND t1._ClientGUID = @ClientGuid
		)

	INSERT INTO @tblCopy
	(
		ID,
		Name,
		ParentID
	)
	SELECT ID,Name,_ParentID from _tmpParents

	DECLARE @counter int

	SET @counter = 1

	WHILE @counter <= (select max(AutoID) from @tblCopy)
	BEGIN
		SELECT TOP 1
			@OldID = ID
		FROM 
			@tblCopy
		WHERE 
			AutoID = @counter

		INSERT INTO IQReport_Folder
		(
			Name,
			_ParentID,
			_ClientGuid
		)   
		output @OldID,inserted.ID into @IdsMapping
		SELECT TOP 1 
				Name,
				ParentID,
				@ClientGuid 
		FROM 
				@tblCopy 
		WHERE 
				AutoID = @counter

		SET @counter = @counter + 1
	END

	UPDATE 
		IQReport_Folder 
	SET  
		_ParentID = @IDtoPaste
	FROM 
		IQReport_Folder 
			INNER JOIN @IdsMapping map
				ON IQReport_Folder.ID = map.New_ID
				AND map.Old_ID = @IDtoCopy

	UPDATE 
		IQReport_Folder
	SET 
		_ParentID =  map.New_Id
	FROM 
		IQReport_Folder AS fldr
			INNER JOIN @IdsMapping AS newfldr
				ON fldr.ID = newfldr.New_Id
			INNER JOIN @IdsMapping AS map
				ON fldr._ParentID = map.Old_Id
END