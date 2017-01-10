
-- EXEC [dbo].[usp_IQAgentSearchRequest_SelectForParentChildRelationship] 14,0,100,'IQ_Local_Air_DateTime',0

CREATE PROCEDURE [dbo].[rm_usp_IQAgentSearchRequest_SelectForParentChildRelationship]
	
	@SearchRequestID		bigint,
	@PageNo					int,
	@PageSize				int	,
	@SortField				varchar(50),
	@IsAscending			bit
	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @StartRow AS INT,@EndRow AS INT
	
	SET @StartRow = (@PageNo * @PageSize) + 1
	SET @EndRow = (@PageNo * @PageSize) + @PageSize
	
	DECLARE @Query as NVARCHAR(MAX)
	
	SET @Query = '
	
	DECLARE @TempTable AS TABLE
	(
		IQAgentResultKey		bigint,
		RL_VideoGUID			uniqueidentifier,		
		Title120				varchar(150),
		StationMarket			varchar(50),
		StationID				varchar(30),
		Number_Hits					int,
		DatabaseKey				varchar(15),
		IQ_Local_Air_DateTime	datetime,
		IQ_Local_Air_Date		date,
		IQ_Dma_Num				varchar(3)
	);
	
	DECLARE @ParentTable AS TABLE
	(		 
		RowIndex				int IDENTITY,
		RowNo					int,
		IQAgentResultKey		bigint,
		RL_VideoGUID			uniqueidentifier,		
		Title120				varchar(150),
		StationMarket			varchar(50),
		StationID				varchar(30),
		Number_Hits					int,
		DatabaseKey				varchar(15),
		IQ_Local_Air_DateTime	datetime,
		IQ_Local_Air_Date		date	
	);

	DECLARE @Table AS TABLE
	(	
		RowNo					int,
		IQAgentResultKey		bigint,
		RL_VideoGUID			uniqueidentifier,				
		Title120				varchar(150),
		StationMarket			varchar(50),
		StationID				varchar(30),
		Number_Hits					int,
		DatabaseKey				varchar(15),
		IQ_Local_Air_DateTime	datetime,
		IQ_Local_Air_Date		date	
	);
	
	Insert into @TempTable
	SELECT 		
				distinct
				IQAgentResults.IQAgentResultKey,
				IQAgentResults.RL_VideoGUID,				
				IQAgentResults.Title120,
				IQAgentResults.RL_Market,
				IQAgentResults.Rl_Station,
				IQAgentResults.Number_Hits,
				IQ_SSP.Database_Key,				
				CONVERT(datetime,CONVERT(varchar(Max),IQAgentResults.RL_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgentResults.RL_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') as IQ_Local_Air_DateTime,
				RL_Date,
				IQ_Dma_Num
		FROM IQAgentResults 
		INNER JOIN IQ_SSP ON IQAgentResults.IQ_CC_Key = IQ_SSP.IQ_CC_Key 
		AND IQAgentResults.IsActive = 1 AND IQAgentResults.SearchRequestID = ' + CAST(@SearchRequestID AS VARCHAR) + ';

	INSERT INTO @Table
		SELECT 		
				ROW_NUMBER() OVER (PARTITION BY IQ_Local_Air_Date,DatabaseKey ORDER BY IQ_Dma_Num,IQ_Local_Air_DateTime desc) as RowNumber,
				IQAgentResultKey,		
				RL_VideoGUID,								
				Title120,				
				StationMarket,
				StationID,			
				Number_Hits,				
				DatabaseKey,					
				IQ_Local_Air_DateTime,
				IQ_Local_Air_Date
		FROM @TempTable as TmpTable
	
	INSERT INTO @ParentTable SELECT * FROM @Table WHERE RowNo = 1 ORDER BY '+ @SortField
	
	IF @IsAscending = 0 
	
		BEGIN
			
			SET @Query = @Query + ' DESC '
			
		END
	
	SET @Query = @Query + '
	
	-- First Select From Parent Table
	
	SELECT * FROM @ParentTable WHERE RowIndex >= ' + CAST(@StartRow AS VARCHAR)  + ' AND RowIndex <= ' + CAST(@EndRow AS VARCHAR)
	
	
	+ 'SELECT MainTable.* FROM @Table as MainTable 
	INNER JOIN @ParentTable as SubTable 
	ON MainTable.DatabaseKey = SubTable.DatabaseKey AND MainTable.IQ_Local_Air_Date  = SubTable.IQ_Local_Air_Date AND SubTable.RowIndex >= ' + CAST(@StartRow AS VARCHAR)  + ' AND SubTable.RowIndex <= ' + CAST(@EndRow AS VARCHAR)
	+ 'WHERE MainTable.RowNo > 1 ORDER BY '+ @SortField
	
	IF @IsAscending = 0 
	
		BEGIN
			
			SET @Query = @Query + ' DESC '
			
		END
	
	SET @Query = @Query + '
	
	SELECT
			SearchTerm.value(''(/IQAgentRequest//SearchTerm/node())[1]'', ''nvarchar(max)'') as SearchTerm
	FROM
			IQAgentSearchRequest
	
	WHERE 
			SearchRequestKey = ' + CAST(@SearchRequestID AS VARCHAR) + 'AND 
			dbo.IQAgentSearchRequest.IsActive=1
	
	Select
			COUNT(TempTable.RowNo) as TotalRecords
	From
			@ParentTable as TempTable '
	
	print @Query
			
	EXEC SP_EXECUTESQL @Query
			
    
END
