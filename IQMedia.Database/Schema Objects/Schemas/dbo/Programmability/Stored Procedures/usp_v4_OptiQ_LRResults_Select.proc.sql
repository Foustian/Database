CREATE PROCEDURE [dbo].[usp_v4_OptiQ_LRResults_Select]
	@ClientGuid uniqueidentifier,
	@FromDate date,
	@ToDate date,
	@LogoIDList xml,
	@DmaList xml,
	@StationAffilList xml,
	@StationIDList xml,
	@ClassNum varchar(20),
	@RegionNum int,
	@CountryNum int,
	@IsAsc bit,
	@IsMarketSort bit,
	@FromRecordID bigint,
	@PageSize int,
	@IndustryList xml,
	@BrandList xml,
	@SinceID bigint output,
	@TotalResults int output
AS
BEGIN
	SET NOCOUNT ON;
	
	Declare @FDate datetime=NULL,
	        @TDate datetime=NULL
	        
	IF(@FromDate is not null AND @ToDate is not null)
	  BEGIN
		Declare @IsDST bit,
				@gmt decimal(18,2),
				@dst decimal(18,2)				
		Select
				@gmt=Client.gmt,
				@dst=Client.dst
		From
				Client
		Where
				ClientGUID = @ClientGUID
	
		SET @FDate = @FromDate
		SET @TDate = DATEADD(MINUTE,1439,Convert(datetime, @ToDate))
				
		Select @IsDST = dbo.fnIsDayLightSaving(@FDate);

		If(@IsDST=1)
		  BEGIN				
			Set @FDate = DATEADD(HOUR,-(@gmt),CONVERT(datetime,@FDate))
			Set @FDate = DATEADD(HOUR,-@dst,CONVERT(datetime, @FDate))
		  END
		ELSE
		  BEGIN
			Set @FDate = DATEADD(HOUR,-(@gmt),CONVERT(datetime, @FDate))
		  END

		Select @IsDST = dbo.fnIsDayLightSaving(@TDate);

		If(@IsDST=1)
		  BEGIN
			Set @TDate = DATEADD(HOUR,-(@gmt),@TDate)
			Set @TDate = DATEADD(HOUR,-@dst,@TDate)
		  END
		ELSE
		  BEGIN
			Set @TDate = DATEADD(HOUR,-(@gmt),@TDate)
		  END
	  END
	
	DECLARE @tempTable table(RowNum bigint, IQ_CC_Key varchar(50), Title120 varchar(100), StationID varchar(20), StationDT datetime, RecordfileGUID uniqueidentifier, HitCount smallint)
	
	Declare @dma table (t_Dma_list varchar(70))
	Declare @station table (t_Station_list varchar(70))
	Declare @station_aff table (t_Station_aff_list varchar(70))
	Declare @Industry table (t_Industry_list varchar(70))
	Declare @Brand table (t_Brand_list varchar(70))
	Declare @Logo table (t_Logo_list varchar(70))

	IF @dmaList IS NOT NULL
	   Insert into @dma
	      select  N.value('@id', 'varchar(70)')  from @dmaList.nodes('/list[1]/item') as T(N) -- if only one root node for performance reason using [1]
	 
	IF @StationAffilList IS NOT NULL
	   Insert into @station_aff
	      select  N.value('@id', 'varchar(70)')  from @StationAffilList.nodes('/list[1]/item') as T(N) 
	  
	IF @StationIDList IS NOT NULL
	   Insert into @station
	      select  N.value('@id', 'varchar(70)')  from @StationIDList.nodes('/list[1]/item') as T(N) 
	
	IF @IndustryList IS NOT NULL
	   Insert into @Industry
	      select  N.value('@id', 'varchar(70)')  from @IndustryList.nodes('/list[1]/item') as T(N) 

	IF @BrandList IS NOT NULL
	   Insert into @Brand
	      select  N.value('@id', 'varchar(70)')  from @BrandList.nodes('/list[1]/item') as T(N) 

	IF @LogoIDList IS NOT NULL
	   Insert into @Logo
	      select  N.value('@id', 'varchar(70)')  from @LogoIDList.nodes('/list[1]/item') as T(N) 

	-- Only return records that have at least 1 search logo match for each selected display logo
	DECLARE @NumLogos int = NULL
	IF @LogoIDList IS NOT NULL
	  BEGIN
		SELECT @NumLogos = @LogoIDList.value('count(/list/item)', 'int')
	  END
	  
	;WITH tblIQCCKeys AS
	(
		SELECT	IQ_CC_Key
		FROM	IQMediaGroup.dbo.IQ_LR_Results results WITH (NOLOCK)
		INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images searchImages ON searchImages.ID = results._SearchLogoID
		WHERE	@LogoIDList IS NULL OR searchImages.Brand_ID in (select l.t_Logo_list from @Logo l)
	--	WHERE	@LogoIDList IS NULL OR @LogoIDList.exist('/list/item[@id=sql:column("searchImages.Brand_ID")]') = 1
				AND results.IsActive = 1
		GROUP	BY IQ_CC_Key
		HAVING	COUNT(DISTINCT searchImages.Brand_ID) >= @NumLogos OR @LogoIDList IS NULL
	)
		
    INSERT	INTO @tempTable
    SELECT	ROW_NUMBER() OVER (order by 
						(Case When @IsMarketSort = 1 AND @IsAsc = 1 Then Dma_Name END),
						(Case When @IsMarketSort = 1 AND @IsAsc = 0 Then Dma_Name END) desc,
						(Case When @IsMarketSort = 0 AND @IsAsc = 1 Then StationDT END),
						(Case @IsAsc When 0 Then StationDT END) desc) AS RowNum,
			results.IQ_CC_Key,
			Title120,
			StationID,
			StationDT,
			RecordfileGUID,
			SUM(results.Hit_Count)
    FROM	 IQMediaGroup.dbo.IQ_LR_Results results WITH (NOLOCK)
    INNER	JOIN tblIQCCKeys ON results.IQ_CC_Key = tblIQCCKeys.IQ_CC_Key
    INNER	JOIN IQMediaGroup.dbo.IQ_Station station ON results.StationID = station.IQ_Station_ID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images searchImages ON searchImages.ID = results._SearchLogoID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Brand brand on brand.ID = searchImages.Brand_ID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Industry industry on industry.ID = brand._IndustryID
    WHERE	results.IsActive = 1
			AND searchImages.IsActive = 1
			AND brand.IsActive = 1
			AND (@SinceID IS NULL OR results.ID <= @SinceID)
			AND (@DmaList IS NULL OR station.Dma_Name in (select d.t_Dma_list from @dma d))
			AND (@StationAffilList IS NULL OR station.Station_Affil in (select sa.t_Station_aff_list from @station_aff sa))
			AND (@StationIDList IS NULL OR results.StationID in (select s.t_Station_list from @station s) )
			AND (ISNULL(@ClassNum, '') = '' OR @ClassNum = results.iQClass)
			AND (ISNULL(@RegionNum, '') = '' OR @RegionNum = station.Region_Num)
			AND (ISNULL(@CountryNum, '') = '' OR @CountryNum = station.Country_Num)
			AND ((@FDate IS NULL AND @TDate IS NULL) OR (StationDT BETWEEN @FDate AND @TDate))
			AND (@IndustryList IS NULL OR industry.Industry in (select i.t_Industry_list from @Industry i))
		    AND (@BrandList IS NULL OR brand.Brand in (select b.t_Brand_list from @Brand b))
		--	AND (@IndustryList IS NULL OR @IndustryList.exist('/list/item[@id=sql:column("brand.Industry")]') = 1)
		--	AND (@BrandList IS NULL OR @BrandList.exist('/list/item[@id=sql:column("brand.Brand")]') = 1)
	GROUP	BY results.IQ_CC_Key,
				station.Dma_Name,
				Title120,
				StationID,
				StationDT,
				RecordfileGUID
	
	SELECT	@SinceID = CASE WHEN @SinceID IS NULL THEN MAX(ID) ELSE @SinceID END
	FROM	IQ_LR_Results
	
	SELECT	@TotalResults = COUNT(*)
	FROM	@tempTable
	
	SELECT	temp.IQ_CC_Key,
			Title120,
			Dma_Name,
			RecordfileGUID,
			StationID,
			dbo.fnGetClipAdjustedDateTime(StationDT, gmt_adj, dst_adj, 0) as StationDT,
			TimeZone,
			temp.HitCount
	FROM	@tempTable temp
    INNER	JOIN IQ_Station ON temp.StationID = IQ_Station.IQ_Station_ID
	WHERE	RowNum > @FromRecordID AND RowNum <= (@FromRecordID + @PageSize)
    ORDER	BY RowNum
    
    SELECT	DISTINCT searchImages.Brand_ID as LogoID,
			Brand as CompanyName,
			rootPath.StreamSuffixPath + brand.Filepath + brand.Logo_thumbs as ThumbnailPath
    FROM	IQMediaGroup.dbo.IQ_LR_Results results WITH (NOLOCK) 
    INNER	JOIN @tempTable temp ON temp.IQ_CC_Key = results.IQ_CC_Key
    INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images searchImages ON searchImages.ID = results._SearchLogoID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Brand brand ON brand.ID = searchImages.Brand_ID
	INNER	JOIN IQMediaGroup.dbo.IQCore_RootPath rootPath ON rootPath.ID = brand.RPID
	ORDER	BY Brand_ID
	
	SELECT	DISTINCT Dma_Name
	FROM	IQ_Station 
	INNER	JOIN @tempTable temp ON temp.StationID = IQ_Station.IQ_Station_ID
	
	SELECT	DISTINCT Station_Affil
	FROM	IQ_Station 
	INNER	JOIN @tempTable temp ON temp.StationID = IQ_Station.IQ_Station_ID
	
	SELECT	DISTINCT IQ_Station_ID,
			Station_Call_Sign
	FROM	IQ_Station 
	INNER	JOIN @tempTable temp ON temp.StationID = IQ_Station.IQ_Station_ID
	
	SELECT	DISTINCT Region,
			Region_Num
	FROM	IQ_Station 
	INNER	JOIN @tempTable temp ON temp.StationID = IQ_Station.IQ_Station_ID
	
	SELECT	DISTINCT Country,
			Country_Num
	FROM	IQ_Station 
	INNER	JOIN @tempTable temp ON temp.StationID = IQ_Station.IQ_Station_ID
	
	SELECT	DISTINCT iQClass
	FROM	IQ_LR_Results WITH (NOLOCK)
	INNER	JOIN @tempTable temp ON temp.IQ_CC_Key = IQ_LR_Results.IQ_CC_Key

	SELECT  DISTINCT industry.Industry
	FROM	IQMediaGroup.dbo.IQ_LR_Brand brand
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Industry industry on industry.ID = brand._IndustryID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images searchImages ON searchImages.Brand_ID = brand.ID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Results results ON results._SearchLogoID = searchImages.ID
	INNER	JOIN @tempTable temp on temp.IQ_CC_Key = results.IQ_CC_Key
	ORDER	BY Industry

	SELECT  DISTINCT Brand
	FROM	IQMediaGroup.dbo.IQ_LR_Brand brand
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Search_Images searchImages ON searchImages.Brand_ID = brand.ID
	INNER	JOIN IQMediaGroup.dbo.IQ_LR_Results results ON results._SearchLogoID = searchImages.ID
	INNER	JOIN @tempTable temp on temp.IQ_CC_Key = results.IQ_CC_Key
	ORDER	BY Brand
END



