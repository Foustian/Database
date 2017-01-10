-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Website ==> MyIQ Report
			--		This Will get data from ArchiveNM table by Fromdate and Todate and CategoryGuid selected
			--		This will include CompeteData if @IsCompeteData is True
-- =============================================
CREATE PROCEDURE [dbo].[usp_Report_myiq_ArchiveNM_SelectByDurationNCategory]
	@ClientGUID uniqueidentifier,
	@SortField			VARCHAR(250),
	@IsAscending		bit,
	@FromDate		date,
	@ToDate		date,
	@CategoryGUID		uniqueidentifier,
	@IsCompeteData		bit
AS
BEGIN
	SET NOCOUNT ON 
	
	DECLARE @Query NVARCHAR(MAX)
	SET @Query = ''
	
	IF(@IsCompeteData = 1)
	BEGIN
	Set @Query = 'DECLARE @OtherOnlineAdRate decimal(18,2)
									DECLARE @CompeteMultiplier decimal(18,2)
									DECLARE @OnlineNewsAdRate decimal(18,2)
									DECLARE @URLPercentRead decimal(18,2)

									SET @OtherOnlineAdRate = 1 
									SET @CompeteMultiplier = 1 
									SET @OnlineNewsAdRate= 1 
									Set @URLPercentRead = 1

									;WITH TEMP_ClientSettings AS
									(
										SELECT
												ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
												Field,
												Value
										FROM
												IQClient_CustomSettings
										Where
												(IQClient_CustomSettings._ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+''' OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
												AND IQClient_CustomSettings.Field IN (''OtherOnlineAdRate'',''CompeteMultiplier'',''OnlineNewsAdRate'',''URLPercentRead'')
									)
								 
									SELECT 
										@OtherOnlineAdRate = [OtherOnlineAdRate],
										@CompeteMultiplier = [CompeteMultiplier],
										@OnlineNewsAdRate= [OnlineNewsAdRate],
										@URLPercentRead = [URLPercentRead]  
									FROM
										(
										  SELECT
												
													[Field],
													[Value]
										  FROM
													TEMP_ClientSettings
										  WHERE	
													RowNum =1
										) AS SourceTable
										PIVOT
										(
											Max(Value)
											FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead])
										) AS PivotTable'
		END
		
										
	SET @Query = @Query + ' ;WITH TempIQCore_Article  '
	SET @Query = @Query + ' AS ( '
	
	SET @Query = @Query + ' Select  ROW_NUMBER() OVER (ORDER BY '
	
	IF @SortField IS NOT NULL AND @SortField != ''
		BEGIN		
				set @Query = @Query + @SortField	
		END
	ELSE
		BEGIN
				SET @Query = @Query + ' ARchiveNM.CreatedDate'
		END
	
	IF @IsAscending=0
		BEGIN
				SET @Query = @Query + ' DESC '
		END
    
    SET @Query = @Query + 	') as RowNumber,
    
		ARchiveNM.ARchiveNMKey,
		ARchiveNM.Title,
		ARchiveNM.ArticleID,
		ARchiveNM.FirstName,
		ARchiveNM.LastName,
		ArchiveNM.CreatedDate,
		ArchiveNM.Url,
		ArchiveNM.harvest_time,
		ArchiveNM.Publication,
		ArchiveNM.Description,ARchiveNM.CategoryGuid,CustomCategory.CategoryName
		'
		IF(@IsCompeteData = 1)
		BEGIN
			 SET @Query = @Query  +',CASE WHEN (c_uniq_visitor IS NULL OR @CompeteMultiplier > 1)THEN
										CAST(0 AS BIT)
									ELSE
										CAST(1 AS BIT)
									END as IsCompeteAll,
									
									CASE 
										WHEN 
											(
											(ArchiveNM.CompeteURL = ''facebook.com'' OR ArchiveNM.CompeteURL = ''twitter.com'' OR ArchiveNM.CompeteURL = ''friendfeed.com'') 											
											)
												THEN -1			 
										WHEN c_uniq_visitor IS NULL THEN
										((((SELECT convert(float,c_uniq_visitor) FROM IQ_Compete_Averages WHERE CompeteURL = ArchiveNM.CompeteURL)/30)*@CompeteMultiplier * (@URLPercentRead/100))/1000)* @OnlineNewsAdRate 
									ELSE
										(((convert(float,c_uniq_visitor)/30)*@CompeteMultiplier * (@URLPercentRead/100))/1000)* @OnlineNewsAdRate
									END as IQ_AdShare_Value,
									
									
									CASE 
										WHEN 
											(
											(ArchiveNM.CompeteURL = ''facebook.com'' OR ArchiveNM.CompeteURL = ''twitter.com'' OR ArchiveNM.CompeteURL = ''friendfeed.com'') 
											)
												THEN -1
										WHEN c_uniq_visitor IS NULL THEN
											(SELECT c_uniq_visitor FROM IQ_Compete_Averages WHERE CompeteURL = ArchiveNM.CompeteURL)
										ELSE
											c_uniq_visitor
										END AS c_uniq_visitor,
									
									Case 
										WHEN
											(IQ_CompeteAll.WebSiteUrl Is Null 
												AND 
												(
													(Select WebSiteUrl from IQ_Compete_Averages Where CompeteURL = ArchiveNM.CompeteURL) is null
													)
											)
											Then
											CAST(0 AS BIT)
										ELSE
											CAST(1 AS BIT)
									END as IsUrlFound
										'
		END
	 SET @Query = @Query + ' FROM
			ArchiveNM
			INNER JOIN CustomCategory 
			ON ArchiveNM.CategoryGuid = CustomCategory.CategoryGUID'
			
			IF(@IsCompeteData = 1)
		BEGIN
			SET @Query = @Query + ' LEFT OUTER JOIN IQ_CompeteAll
				ON ArchiveNM.CompeteURL = IQ_CompeteAll.CompeteURL'
		END
		
	SET @Query = @Query + ' WHERE
			ARchiveNM.ClientGuid='''+CONVERT(varchar(40),@ClientGUID)+''''
			IF(@CategoryGUID IS NOT NULL)
				BEGIN
				SET @Query = @Query +  ' AND ARchiveNM.CategoryGuid = '''+ CONVERT(varchar(40),@CategoryGUID) +''''
				END
			
			SET @Query = @Query + ' AND CONVERT(date,ARchiveNM.CreatedDate) between CONVERT(date,'''+CONVERT(varchar(10),@FromDate) +''') and CONVERT(date,'''+CONVERT(varchar(10),@ToDate) +''')
			 AND ARchiveNM.IsActive = 1)'
	
	
	SET  @Query = @Query + ' SELECT * FROM TempIQCore_Article '
	
	
	
	print @Query 
	
	EXEC sp_executesql @Query
END
