-- =============================================
-- Author:		<Author,,Name>
-- Create date: 26 June 1013
-- Description:	Select record based on ID
-- =============================================
CREATE PROCEDURE [dbo].[usp_v5_IQAgent_MediaResults_SelectByID]
	@ID		BIGINT,
	@ClientGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @_MediaID AS BIGINT,@MediaType AS VARCHAR(10),@MediaCategory AS VARCHAR(50),@ArticleID AS VARCHAR(50),@DataModelType AS VARCHAR(2)

	SELECT	@_MediaID = _MediaID,
			@MediaType = v5MediaType,
			@MediaCategory = v5Category,
			@DataModelType = DataModelType
	FROM	IQAgent_MediaResults WITH (NOLOCK)
				INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
					ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID
				INNER JOIN IQ_MediaTypes
					ON IQ_MediaTypes.SubMediaType = IQAgent_MediaResults.v5Category
	WHERE	
			@ID = IQAgent_MediaResults.ID AND IQAgent_MediaResults.IsActive = 1 And IQAgent_SearchRequest.ClientGUID = @ClientGuid
	
	IF @DataModelType Is NOT NULL AND @DataModelType = 'NM'
		BEGIN
			SELECT 
					ArticleID,
					@MediaType as MediaType,
					@MediaCategory as SubMediaType,
					IQAgent_NMResults.Url,
					IQAgent_NMResults.harvest_time,
					IQAgent_NMResults.Title,
					IQAgent_MissingArticles.Content,
					IQAgent_NMResults.Publication,
					IQAgent_NMResults.CompeteUrl,
					case when IQAgent_MissingArticles.ID is null then 0 else 1 end as IsMissingArticle,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					IQAgent_MediaResults.IQProminence,
					IQAgent_MediaResults.IQProminenceMultiplier,
					@DataModelType as DataModelType
			FROM	
				IQAgent_NMResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_NMResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.v5Category = @MediaCategory
					left outer join IQAgent_MissingArticles  WITH (NOLOCK)
						on IQAgent_NMResults.ArticleID = IQAgent_MissingArticles.ID
						and IQAgent_MissingArticles.Category ='NM'
			WHERE	IQAgent_NMResults.ID = @_MediaID 

		END
	
	IF @DataModelType Is NOT NULL AND @DataModelType = 'SM'
		BEGIN
			SELECT 
					SeqID as ArticleID,
					@MediaType as MediaType,
					@MediaCategory as SubMediaType,
					IQAgent_SMResults.link as Url,
					IQAgent_SMResults.itemHarvestDate_DT as harvest_time,
					IQAgent_SMResults.[description] as Title,
					IQAgent_MissingArticles.Content,
					IQAgent_SMResults.homelink as Publication,
					IQAgent_SMResults.CompeteUrl,
					IQAgent_SMResults.feedClass,
					case when IQAgent_MissingArticles.ID is null then 0 else 1 end as IsMissingArticle,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					IQAgent_SMResults.HighlightingText,
					IQAgent_SMResults.ThumbUrl,
					IQAgent_SMResults.ArticleStats,
					IQAgent_SMResults.IQProminence,
					IQAgent_SMResults.IQProminenceMultiplier,
					@DataModelType as DataModelType
			FROM	
				IQAgent_SMResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_SMResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.v5Category = @MediaCategory
					left outer join IQAgent_MissingArticles  WITH (NOLOCK)
						on IQAgent_SMResults.SeqID = CAST(IQAgent_MissingArticles.ID AS VARCHAR(MAX)) -- Facebook SeqIDs are non-numeric
						and IQAgent_MissingArticles.Category != 'NM'
			WHERE	IQAgent_SMResults.ID = @_MediaID 
		END 
		
	IF @DataModelType Is NOT NULL AND @DataModelType = 'TW'
		BEGIN
			SELECT 
					TweetID as ArticleID,
					@MediaType as MediaType,
					@MediaCategory as SubMediaType,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					@DataModelType as DataModelType
			FROM	IQAgent_TwitterResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_TwitterResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.v5Category = @MediaCategory
			WHERE	IQAgent_TwitterResults.ID = @_MediaID 
		END
	IF @DataModelType Is NOT NULL AND @DataModelType = 'PQ'
		BEGIN
			SELECT
					ProQuestID as ArticleID,
					@MediaType as MediaType,
					@MediaCategory as SubMediaType,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					@DataModelType as DataModelType
			FROM
					IQAgent_PQResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_PQResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.v5Category = @MediaCategory
			WHERE	IQAgent_PQResults.ID = @_MediaID
		END
	IF @DataModelType Is NOT NULL AND @DataModelType = 'TM'
		BEGIN
			SELECT
					@_MediaID as ArticleID,
					@MediaType as MediaType,
					@MediaCategory as SubMediaType,
					IQAgent_MediaResults.PositiveSentiment,
					IQAgent_MediaResults.NegativeSentiment,
					@DataModelType as DataModelType
			FROM
					IQAgent_TVEyesResults WITH (NOLOCK)
					inner join IQAgent_MediaResults WITH (NOLOCK)
						on IQAgent_TVEyesResults.ID = IQAgent_MediaResults._MediaID
						and IQAgent_MediaResults.v5Category = @MediaCategory
			WHERE	IQAgent_TVEyesResults.ID = @_MediaID				
		END
END
