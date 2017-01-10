
CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_MediaResults_UpdatedRecords_SelectByClientGUID]
(
	@ClientGUID	UNIQUEIDENTIFIER,
	@SeqID	BIGINT,
	@PageSize	INT
)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @TotalResults BIGINT, @MaxSinceID BIGINT
	
	SELECT 
			@TotalResults = COUNT(IQAgent_MediaResults_UpdatedRecords.ID),
			@MaxSinceID = MAX(IQAgent_MediaResults_UpdatedRecords.ID)
	FROM
			IQAgent_MediaResults_UpdatedRecords
							
	WHERE
			ClientGUID=@ClientGUID
		AND SolrStatus=1
		AND (UpdateType IS NULL OR UpdateType = 0)
	
	SELECT
			TOP(@PageSize)
			IQAgent_MediaResults_UpdatedRecords.ID,
			IQAgent_MediaResults_UpdatedRecords._MediaResultID	
	FROM
			IQAgent_MediaResults_UpdatedRecords
			
	WHERE
			ClientGUID=@ClientGUID
		AND SolrStatus=1
		AND (UpdateType IS NULL OR UpdateType = 0)
		AND (@SeqID IS NULL OR IQAgent_MediaResults_UpdatedRecords.ID > @SeqID)

	ORDER BY 
			IQAgent_MediaResults_UpdatedRecords.ID ASC	
					
	SELECT
			@TotalResults TotalResults,
			@MaxSinceID SinceID
	
END
