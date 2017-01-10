CREATE PROCEDURE [dbo].[usp_pshell_IQAgent_MediaResults_Delete]
	@DeleteControlID bigint,
	@RowAffected INT OUTPUT
AS

-- Modified Date :	May 2015
-- Description   : To include scanning the Media Archive tables for Media delete and Day-Hour Summary.
--                  Calling the usp_v4_IQAgent_MediaResults_Delete_Get_Day_Hour_Summary and usp_v4_IQAgent_MediaResults_Delete_Process stored procdures with recompile option, so it can benefit temp table's indexes.
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
BEGIN TRY  		

	DECLARE @ClientGUID UNIQUEIDENTIFIER
	DECLARE @ID VARCHAR(MAX)

	SELECT @ClientGUID = clientGUID,
			@ID = COALESCE(@ID + ',', '') + Deletes.ID.value('.', 'varchar(100)')
	FROM IQAgent_DeleteControl WITH (NOLOCK)
	CROSS APPLY statusUpdateData.nodes('add/doc/field[@name="iqseqid"]') as Deletes(ID)
	WHERE IQAgent_DeleteControl.ID = @DeleteControlID

	SET @ID=REPLACE(@ID,'''','')

	DECLARE @IDListTbl TABLE (ID BIGINT NOT NULL PRIMARY KEY)
	DECLARE	@GMT INT,
			@DST INT,
			@WDST INT,
			@status smallint
	
	SELECT
			@GMT= gmt,
			@DST=dst,
			@WDST=gmt+dst
	FROM
			 Client WHERE ClientGuid = @ClientGUID
	

	INSERT INTO @IDListTbl
	(	
		ID
	)
	SELECT ID FROM ufnGetIntTableFromStringsFn(@ID)
	
--#region MediaResult table var contains records to delete

	declare @TblSelectMR table
	(
		[ID] bigint not null,
		[_ParentID] bigint null,
		SearchRequestID bigint null
	)
	
	insert into @TblSelectMR
	(
		[ID],
		[_ParentID],
		SearchRequestID
	)
	SELECT
		IQAgent_MediaResults.ID,		
		_ParentID,
		_SearchRequestID	
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults.ID

	Create table #TblMediaResults 
	(
		[ID] BIGINT NOT NULL
		
	)
	
	INSERT INTO #TblMediaResults
	(
		ID
		
	)
	SELECT
		IQAgent_MediaResults.ID
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults.ID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults.IsActive=1
				AND	IQAgent_SearchRequest.IsActive>0
	UNION
	
	SELECT
		IQAgent_MediaResults.ID
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults._ParentID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults.IsActive=1
				AND	IQAgent_SearchRequest.IsActive>0


	---- May 2015, Doing the same processes for the IQAgent_MediaResults_Archive_xxxx tables through the IQAgent_MediaResults_Archive view, because active media being getting archived (to resolve a performance issue on the huge IQAgent_MediaResults)
	---- Also doing scanning  on the media child tables in the usp_v4_IQAgent_MediaResults_Delete_Get_Day_Hour_Summary @ClientGUID

	INSERT INTO #TblMediaResults
	(
		ID
	)
	SELECT
		IQAgent_MediaResults_Archive.ID
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults_Archive WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults_Archive.ID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults_Archive._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults_Archive.IsActive=1
				AND	IQAgent_SearchRequest.IsActive>0
	UNION
	
	SELECT
		IQAgent_MediaResults_Archive.ID
	FROM
		@IDListTbl AS TmpIDList
			INNER JOIN IQAgent_MediaResults_Archive WITH(NOLOCK)
				ON		TmpIDList.ID=IQAgent_MediaResults_Archive._ParentID
			INNER JOIN IQAgent_SearchRequest WITH(NOLOCK)
				ON		IQAgent_MediaResults_Archive._SearchRequestID=IQAgent_SearchRequest.ID
					AND	IQAgent_SearchRequest.ClientGUID=@ClientGUID
			WHERE
					IQAgent_MediaResults_Archive.IsActive=1
				AND	IQAgent_SearchRequest.IsActive>0

--#endregion

IF (SELECT COUNT(1) FROM #TblMediaResults) > 0
  BEGIN
    Create index idx1_TblMediaResults on #TblMediaResults (ID)
   
    exec @status=dbo.usp_v4_IQAgent_MediaResults_Delete_Process @ClientGUID, @RowAffected= @RowAffected OUTPUT With recompile

	drop table #TblMediaResults
  END
ELSE
  BEGIN
	-- If all of the records to be deleted are already deleted, return 1 to indicate success
	SELECT @RowAffected = 1
  END  
END TRY
		BEGIN CATCH
		
		--	IF(@@TRANCOUNT>0)
		--	BEGIN		          
		--		ROLLBACK TRANSACTION;  
		--	END
			
			SELECT @RowAffected = 0  
			
			DECLARE @IQMediaGroupExceptionKey BIGINT,
			@ExceptionStackTrace VARCHAR(500),
			@ExceptionMessage VARCHAR(500),
			@CreatedBy	VARCHAR(50),
			@ModifiedBy	VARCHAR(50),
			@CreatedDate	DATETIME,
			@ModifiedDate	DATETIME,
			@IsActive	BIT
			
	
			SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v4_IQAgent_MediaResults_Delete',
				@ModifiedBy='usp_v4_IQAgent_MediaResults_Delete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
		END CATCH        

END