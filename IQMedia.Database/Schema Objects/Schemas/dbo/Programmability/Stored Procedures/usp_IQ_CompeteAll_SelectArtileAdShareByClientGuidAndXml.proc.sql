CREATE PROCEDURE [dbo].[usp_IQ_CompeteAll_SelectArtileAdShareByClientGuidAndXml]
	@ClientGuid uniqueidentifier,
	@PublicationXml xml,
	@MediaType	varchar(2)
AS
BEGIN
	DECLARE @OtherOnlineAdRate decimal(18,2)
	DECLARE @CompeteMultiplier decimal(18,2)
	DECLARE @OnlineNewsAdRate decimal(18,2)
	DECLARE @URLPercentRead decimal(18,2)
	DECLARE @CompeteAudienceMultiplier decimal(18,2)

	SET @OtherOnlineAdRate = 1 
	SET @CompeteMultiplier = 1 
	SET @OnlineNewsAdRate= 1 
	Set @URLPercentRead = 1
	SET @CompeteAudienceMultiplier = 1 

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

	SELECT 	
			x.y.value('@url','varchar(max)') as CompeteURL,	
			CASE 
				WHEN (isnull(c_uniq_visitor, 0) <= 0 OR results <> 'A' OR @CompeteAudienceMultiplier != 1 OR 
						(@MediaType = 'SM' and ((IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Blog') AND (IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Comment')))) 
				THEN
					CAST(0 AS BIT)
				ELSE
					CAST(1 AS BIT)
			END as IsCompeteAll,			
			CASE 
				WHEN 
					(
					(x.y.value('@url','varchar(max)') = 'facebook.com' OR x.y.value('@url','varchar(max)') = 'twitter.com' OR x.y.value('@url','varchar(max)') = 'friendfeed.com') 
					OR
					(@MediaType = 'SM' and ((IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Blog') AND (IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Comment')))
					)
				THEN 
					-1			 
				ELSE
					(((convert(decimal(18,2),c_uniq_visitor)/30)*@CompeteMultiplier * @CompeteAudienceMultiplier * (convert(decimal(18,2),@URLPercentRead)/100))/1000)* CASE WHEN @MediaType = 'NM' THEN @OnlineNewsAdRate ELSE @OtherOnlineAdRate END
			END as IQ_AdShare_Value,			
			CASE 
				WHEN 
					(
					(x.y.value('@url','varchar(max)') = 'facebook.com' OR x.y.value('@url','varchar(max)') = 'twitter.com' OR x.y.value('@url','varchar(max)') = 'friendfeed.com') 
					OR
					(@MediaType = 'SM' and ((IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Blog') AND (IsNull(x.y.value('@sourceCategory','varchar(max)'),'') <> 'Comment')))
					)
				THEN 
					-1
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
			END AS IsUrlFound

	FROM
			@PublicationXml.nodes('list/item') x(y) LEFT OUTER JOIN IQ_CompeteAll
				ON x.y.value('@url','varchar(max)') = IQ_CompeteAll.CompeteURL

END
