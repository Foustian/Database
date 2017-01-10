CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectByRadioStationsIQCCKey_Service]
(
	@IQCCKey		varchar(Max),
	@PageNumber		int,
	@PageSize		int,
	@SortField		VARCHAR(250),
	@TotalRecordsCount int output
)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT	
		
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
				
	SET @StartRowNo = (((@PageNumber * @PageSize) + 1)-@PageSize)
	SET @EndRowNo   = (@PageNumber * @PageSize)
	
	Declare @Query nvarchar(Max)
	
	set @Query='WITH IQMediaRL_GUIDS  AS ( Select  ROW_NUMBER() OVER (Order by '
	
		
			IF @SortField IS NOT NULL and @SortField <> ''
				BEGIN
						SET @SortField=REPLACE(@SortField,'DateTime',' CONVERT(varchar(19),CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00'') ')
						SET @SortField = REPLACE(@SortField,'-',' desc')
						set @Query = @Query + @SortField
				END
			ELSE
				BEGIN
					SET @Query = @Query + ' RL_GUIDS.RL_Station_ID '
				END	
			
		
		
     SET @Query = @Query + 	') as RowNumber,'
	 set @Query=@Query +'Convert(uniqueidentifier,RL_GUIDS.RL_GUID) as RL_GUID,
			RL_GUIDS.RL_Station_ID,
			dma_name,
			CONVERT(datetime,CONVERT(varchar(Max),RL_GUIDS.RL_Station_Date,101) + '' ''+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),RL_GUIDS.RL_Station_Time)/convert(decimal(5,2),100)))),''.'','':'')+'':00:00'') as DateTime
	From
			RL_GUIDS
				inner join RL_Station
					on RL_GUIDS.RL_Station_ID=RL_Station.RL_Station_ID
	Where
			RL_GUIDS.IsActive=1 and
			RL_GUIDS.IQ_CC_Key in ('+@IQCCKey+'))'
	set @Query=@Query+' SELECT * FROM IQMediaRL_GUIDS Where RowNumber >=' + CAST(@StartRowNo as VARCHAR) + ' AND RowNumber <= ' + CAST(@EndRowNo as VARCHAR)

	PRINT @Query
	
	exec sp_executesql @Query
	

	
	DECLARE @CountQuery NVARCHAR(Max)
				
	set @CountQuery='Select @TotalRecordsCount=count(*) from RL_GUIDS Where IQ_CC_Key in ('+@IQCCKey+')'
	
	exec sp_executesql @CountQuery,N'@TotalRecordsCount int output',@TotalRecordsCount output
	
END
