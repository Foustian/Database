CREATE PROCEDURE [dbo].[usp_iqsvc_IQ_CompeteAll_Demographic_Select]
(
	@ClientGuid	UNIQUEIDENTIFIER,
	@CompeteURLXml	XML,
	@SubMediaType	VARCHAR(50)
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @OtherOnlineAdRate decimal(18,2) = 1
	DECLARE @CompeteMultiplier decimal(18,2) = 1
	DECLARE @OnlineNewsAdRate decimal(18,2) = 1
	DECLARE @URLPercentRead decimal(18,2) = 1
	DECLARE @CompeteAudienceMultiplier decimal(18,2) = 1	

	;WITH TEMP_ClientSettings AS
	(
		SELECT
				ROW_NUMBER() OVER (PARTITION BY Field ORDER BY IQClient_CustomSettings._ClientGuid desc) as RowNum,
				Field,
				Value
		FROM
				IQClient_CustomSettings
		Where
				(IQClient_CustomSettings._ClientGuid=@ClientGuid OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
				AND IQClient_CustomSettings.Field IN ('OtherOnlineAdRate','CompeteMultiplier','OnlineNewsAdRate','URLPercentRead','CompeteAudienceMultiplier')
	)

	SELECT 
			@OtherOnlineAdRate = [OtherOnlineAdRate],
			@CompeteMultiplier = [CompeteMultiplier],
			@OnlineNewsAdRate	=		[OnlineNewsAdRate],
			@URLPercentRead		 =	[URLPercentRead],
			@CompeteAudienceMultiplier = [CompeteAudienceMultiplier]
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
			FOR Field IN ([OtherOnlineAdRate],[CompeteMultiplier],[OnlineNewsAdRate],[URLPercentRead],[CompeteAudienceMultiplier])
		) AS PivotTable

	DECLARE @CompeteURLTbl	TABLE (URL	VARCHAR(256), IsSelect BIT)		

	INSERT INTO @CompeteURLTbl
	(
		URL,
		IsSelect
	)
	SELECT 	
			x.y.value('@url','varchar(max)'),
			CASE WHEN (x.y.value('@url','varchar(max)') = 'facebook.com' OR x.y.value('@url','varchar(max)') = 'twitter.com' OR x.y.value('@url','varchar(max)') = 'friendfeed.com') THEN 0 ELSE 1 END
	FROM
			@CompeteURLXml.nodes('list/item') x(y)			


	SELECT 	
			CompeteURLTbl.URL as CompeteURL,	
			CASE 
				WHEN (
						isnull(c_uniq_visitor, 0) <= 0 OR 
						results != 'A' OR 
						@CompeteAudienceMultiplier != 1 
					)						
				THEN
					CAST(0 AS BIT)
				ELSE
					CAST(1 AS BIT)
			END as IsCompeteAll,			
			CASE 
				WHEN 
					(IsSelect = 0)
				THEN 
					NULL
				ELSE
					(((convert(decimal(18,2),c_uniq_visitor)/30)*@CompeteMultiplier * @CompeteAudienceMultiplier * (convert(decimal(18,2),@URLPercentRead)/100))/1000)* CASE WHEN @SubMediaType = 'NM' THEN @OnlineNewsAdRate ELSE @OtherOnlineAdRate END
			END as IQ_AdShare_Value,			
			CASE 
				WHEN 
					(IsSelect = 0)
				THEN 
					NULL
				ELSE
					CONVERT(bigint,round((c_uniq_visitor * @CompeteAudienceMultiplier)/30,0))
			END AS c_uniq_visitor,
			CASE
				WHEN 
					IQ_CompeteAll.ID IS NULL
				THEN
					CAST(0 AS BIT)
				ELSE
					CAST(1 AS BIT)
			END AS IsUrlFound,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_18_24
			END AS MALE_AUDIENCE_18_24,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_25_34
			END AS MALE_AUDIENCE_25_34,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_35_44
			END AS MALE_AUDIENCE_35_44,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_45_54
			END AS MALE_AUDIENCE_45_54,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_55_64
			END AS MALE_AUDIENCE_55_64,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_M_65_PLUS
			END AS MALE_AUDIENCE_ABOVE_65,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_18_24
			END AS FEMALE_AUDIENCE_18_24,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_25_34
			END AS FEMALE_AUDIENCE_25_34,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_35_44
			END AS FEMALE_AUDIENCE_35_44,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_45_54
			END AS FEMALE_AUDIENCE_45_54,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_55_64
			END AS FEMALE_AUDIENCE_55_64,
			CASE 
				WHEN
					(IsSelect  = 0)
				THEN
					NULL
				ELSE
					A_F_65_PLUS
			END AS FEMALE_AUDIENCE_ABOVE_65

	FROM
			@CompeteURLTbl AS CompeteURLTbl 
				LEFT OUTER JOIN IQ_CompeteAll
					ON	CompeteURLTbl.URL = IQ_CompeteAll.CompeteURL

END	