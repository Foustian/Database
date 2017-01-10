
-- EXEC [dbo].[usp_IQAgentSearchRequest_SelectForParentChildRelationship] 14,0,100,'IQ_Local_Air_DateTime',0

CREATE PROCEDURE [dbo].[usp_IQAgentSearchRequest_SelectForParentChildRelationship]
	
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
		ID						bigint,
		RL_VideoGUID			uniqueidentifier,		
		IQ_CC_Key				varchar(28),	
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
		ID						bigint,
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
		ID						bigint,
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
				IQAgent_TVResults.ID,
				IQAgent_TVResults.RL_VideoGUID,
				IQAgent_TVResults.IQ_CC_Key,			
				IQAgent_TVResults.Title120,
				IQAgent_TVResults.RL_Market,
				IQAgent_TVResults.Rl_Station,
				IQAgent_TVResults.Number_Hits,
				IQ_SSP.Database_Key,				
				CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.RL_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') as IQ_Local_Air_DateTime,
				RL_Date,
				IQ_Dma_Num
		FROM IQAgent_TVResults 
		INNER JOIN IQ_SSP ON IQAgent_TVResults.IQ_CC_Key = IQ_SSP.IQ_CC_Key 
		AND IQAgent_TVResults.IsActive = 1 AND IQAgent_TVResults.SearchRequestID = ' + CAST(@SearchRequestID AS VARCHAR) + ';

	INSERT INTO @Table
		SELECT 		
				ROW_NUMBER() OVER (PARTITION BY MAX(IQ_Local_Air_Date),MAX(DatabaseKey) ORDER BY MAX(IQ_Dma_Num),MAX(IQ_Local_Air_DateTime) desc) as RowNumber,
				MAX(ID),		
				RL_VideoGUID,								
				MAX(Title120),				
				MAX(StationMarket),
				MAX(StationID),			
				MAX(Number_Hits),				
				MAX(DatabaseKey),					
				MAX(IQ_Local_Air_DateTime),
				MAX(IQ_Local_Air_Date)
		FROM @TempTable as TmpTable
		GROUP BY IQ_CC_Key,RL_VideoGUID 
	
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
	
	Select
			COUNT(TempTable.RowNo) as TotalRecords
	From
			@ParentTable as TempTable '
	
	print @Query
			
	EXEC SP_EXECUTESQL @Query
			
    
END
