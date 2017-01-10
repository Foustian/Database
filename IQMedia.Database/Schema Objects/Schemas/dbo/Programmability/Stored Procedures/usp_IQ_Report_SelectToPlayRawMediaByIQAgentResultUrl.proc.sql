CREATE PROCEDURE [dbo].[usp_IQ_Report_SelectToPlayRawMediaByIQAgentResultUrl]
	@IQAgentResultUrl VARCHAR(500)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DataModelType		VARCHAR(10)
	DECLARE @IQAgentResultID	BIGINT
	DECLARE @RawMediaGuid		UNIQUEIDENTIFIER
	DECLARE @ExpiryDate			DATETIME
	DECLARE @HighlightingText	NVARCHAR(MAX)
	DECLARE @SearchRequestID	BIGINT
	DECLARE @QueryVersion		INT
	DECLARE @SearchTerm			VARCHAR(MAX)
	
	SELECT	@DataModelType = DataModelType,
			@IQAgentResultID = IQAgentResultID
	FROM	IQMediaGroup.dbo.IQAgentIFrame
	WHERE	Guid = @IQAgentResultUrl
	
	IF @DataModelType = 'TV'
	  BEGIN
		IF EXISTS (SELECT 1 FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
		  BEGIN
			SELECT
					@HighlightingText = CAST(CC_Highlight AS NVARCHAR(MAX)),
					@RawMediaGuid = (CASE	
										WHEN								
											IQagentIFrame.IQAgentResultID IS NOT NULL
										THEN
											RL_VideoGUID
									END
									),
					@ExpiryDate = IQAgentIFrame.[Expiry_Date],
					@SearchRequestID = SearchRequestID,
					@QueryVersion = _QueryVersion
			FROM	IQMediaGroup.dbo.IQAgentIFrame
			LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK)
				ON	IQAgentiFrame.IQAgentResultID = ID
			WHERE	IQAgentiFrame.[Guid] = @IQAgentResultUrl
		  END
		ELSE
		  BEGIN
			SELECT
					@HighlightingText = CAST(CC_Highlight AS NVARCHAR(MAX)),
					@RawMediaGuid = (CASE	
										WHEN								
											IQagentIFrame.IQAgentResultID IS NOT NULL
										THEN
											RL_VideoGUID
									END
									),
					@ExpiryDate = IQAgentIFrame.[Expiry_Date],
					@SearchRequestID = SearchRequestID,
					@QueryVersion = _QueryVersion
			FROM	IQMediaGroup.dbo.IQAgentIFrame
			LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_TVResults_Archive WITH (NOLOCK)
				ON	IQAgentiFrame.IQAgentResultID = ID
			WHERE	IQAgentiFrame.[Guid] = @IQAgentResultUrl
		  END

		SELECT	@SearchTerm = CASE WHEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm/@IsUserMaster)[1]', 'VARCHAR(max)') = 'false'  
									THEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/TV/SearchTerm)[1]', 'VARCHAR(max)')  
									ELSE IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/SearchTerm/node())[1]', 'VARCHAR(max)') END
		FROM	IQMediaGroup.dbo.IQAgent_SearchRequest_History WITH (NOLOCK)
		WHERE	_SearchRequestID = @SearchRequestID
				AND Version = @QueryVersion				
	  END
	ELSE IF @DataModelType = 'IQR'
	  BEGIN
		IF EXISTS (SELECT 1 FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
		  BEGIN
			SELECT
					@HighlightingText = CAST(HighlightingText AS NVARCHAR(MAX)),
					@RawMediaGuid = (CASE	
										WHEN								
											IQagentIFrame.IQAgentResultID IS NOT NULL
										THEN
											IQAgent_RadioResults.Guid
									END
									),
					@ExpiryDate = IQAgentIFrame.[Expiry_Date],
					@SearchRequestID = IQAgentSearchRequestID,
					@QueryVersion = _QueryVersion
			FROM	IQMediaGroup.dbo.IQAgentIFrame
			LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_RadioResults WITH (NOLOCK)
				ON	IQAgentiFrame.IQAgentResultID = ID
			WHERE	IQAgentiFrame.[Guid] = @IQAgentResultUrl
		  END
		ELSE
		  BEGIN
			SELECT
					@HighlightingText = CAST(HighlightingText AS NVARCHAR(MAX)),
					@RawMediaGuid = (CASE	
										WHEN								
											IQagentIFrame.IQAgentResultID IS NOT NULL
										THEN
											IQAgent_RadioResults_Archive.Guid
									END
									),
					@ExpiryDate = IQAgentIFrame.[Expiry_Date],
					@SearchRequestID = IQAgentSearchRequestID,
					@QueryVersion = _QueryVersion
			FROM	IQMediaGroup.dbo.IQAgentIFrame
			LEFT OUTER JOIN IQMediaGroup.dbo.IQAgent_RadioResults_Archive WITH (NOLOCK)
				ON	IQAgentiFrame.IQAgentResultID = ID
			WHERE	IQAgentiFrame.[Guid] = @IQAgentResultUrl
		  END

		SELECT	@SearchTerm = CASE WHEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/IQRadio/SearchTerm/@IsUserMaster)[1]', 'VARCHAR(max)') = 'false'  
									THEN IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/IQRadio/SearchTerm)[1]', 'VARCHAR(max)')  
									ELSE IQAgent_SearchRequest_History.SearchRequest.value('(/SearchRequest/SearchTerm/node())[1]', 'VARCHAR(max)') END
		FROM	IQMediaGroup.dbo.IQAgent_SearchRequest_History WITH (NOLOCK)
		WHERE	_SearchRequestID = @SearchRequestID
				AND Version = @QueryVersion		
	  END
	ELSE
	  BEGIN
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionMessage VARCHAR(500) = 'Encountered unsupported DataModelType: ' + ISNULL(@DataModelType, 'NULL'),
				@CreatedBy VARCHAR(50) = 'usp_IQ_Report_SelectToPlayRawMediaByIQAgentResultUrl',
				@CreatedDate DATETIME = GETDATE()
		
		EXEC usp_IQMediaGroupExceptions_Insert '',@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	  END

	SELECT	@ExpiryDate AS [Expiry_Date],
			@HighlightingText AS CC_Highlight,
			@RawMediaGuid as RawMediaGuid,
			@SearchTerm	 as SearchTerm,
			@DataModelType as DataModelType

END

