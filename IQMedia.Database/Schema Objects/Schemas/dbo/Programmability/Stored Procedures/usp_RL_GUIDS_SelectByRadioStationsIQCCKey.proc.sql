CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectByRadioStationsIQCCKey]
(
	@IQCCKey		varchar(Max),
	@PageNumber		int,
	@PageSize		int,
	@SortField		VARCHAR(250),
	@IsSortDirectionAsc	bit
)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT	
		
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
				
	SET @StartRowNo = (@PageNumber * @PageSize) + 1
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize
	Declare @Query nvarchar(Max)
	
	set @Query='WITH IQMediaRL_GUIDS_CTE  AS ( Select  ROW_NUMBER() OVER (Order by '
	IF @SortField IS NOT NULL OR @SortField <> ''
							BEGIN
							
								IF @SortField = 'DateTime'
									BEGIN
										SET @Query = @Query + ' CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') '
									END
								ELSE
									BEGIN
										set @Query = @Query + @SortField	
									END
								
								IF @IsSortDirectionAsc = 0 
									BEGIN
										SET @Query = @Query + ' DESC '
									END
							END
						ELSE
							BEGIN
								SET @Query = @Query + ' Station_ID '
							END
     SET @Query = @Query + 	') as RowNumber,'
	 set @Query=@Query +'RL_GUIDS.RL_GUID,
			RL_GUIDS.RL_Station_ID,
			dma_name,
			RL_Station_Date,
			RL_Station_Time
	From
			RL_GUIDS
				inner join RL_Station
					on RL_GUIDS.RL_Station_ID=RL_Station.RL_Station_ID
	Where
			RL_GUIDS.IsActive=1 and
			RL_GUIDS.IQ_CC_Key in ('+@IQCCKey+'))'
	set @Query=@Query+' SELECT * FROM IQMediaRL_GUIDS_CTE Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)
	print @Query
	exec sp_executesql @Query
	
	DECLARE @CountQuery NVARCHAR(Max)
				
	set @CountQuery='Select count(*) from RL_GUIDS Where IQ_CC_Key in ('+@IQCCKey+')'
	
	exec sp_executesql @CountQuery
	
END
