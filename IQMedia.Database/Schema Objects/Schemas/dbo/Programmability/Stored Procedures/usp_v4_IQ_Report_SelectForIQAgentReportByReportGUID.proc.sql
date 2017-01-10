-- =============================================
-- Author:		<Author,,Name>
-- Create date: 9 July 2013
-- Description:	Select for Report IQAgent by Report GUID
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SelectForIQAgentReportByReportGUID]
	@ReportGUID			UNIQUEIDENTIFIER,
	@MaxDisplayRecord	INT,
	@IsSourceEmail		BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportXML AS XML,@ReportTitle AS VARCHAR(500),@ReportImage varchar(255),@ClientGuid UNIQUEIDENTIFIER
	DECLARE @NielsenAccess bit, @CompeteAccess bit
	
	SELECT	@ReportTitle = Title,
			@ReportXML = ReportRULE,
			@ReportImage = Location,
			@ClientGuid = IQ_Report.ClientGuid
	FROM	IQ_Report 
	INNER JOIN IQ_ReportType
	ON IQ_Report._ReportTypeID = IQ_ReportType.ID
	LEFT OUTER JOIN IQClient_CustomImage 
		ON IQClient_CustomImage._ClientGUID = IQ_Report.ClientGuid
		AND IQClient_CustomImage.IsDefault = 1 AND IQClient_CustomImage.IsActive = 1
	WHERE IQ_ReportType.[Identity] = 'DailyReport' AND ReportGUID = @ReportGUID
	AND		IQ_Report.IsActive = 1
	AND		IQ_ReportType.IsActive = 1


	SET @NielsenAccess = 0
	SET @CompeteAccess =0

	Select 
		@NielsenAccess = NielSenData,
		@CompeteAccess  = CompeteData
	FROM
	(
		SELECT
			Rolename  ,   
			CAST(ClientRole.IsAccess AS INT) AS IsAccess
		
		FROM         
			dbo.Role INNER JOIN
			dbo.ClientRole ON dbo.Role.RoleKey = dbo.ClientRole.RoleID INNER JOIN
			dbo.Client on ClientRole.ClientID = Client.ClientKey
			and Client.IsActive = 1 and ClientRole.IsAccess = 1 and role.IsActive = 1
		
		WHERE
			Client.ClientGuid = @ClientGuid
	) as a pivot
	(
	max([IsAccess])
	FOR [RoleName] IN ([NielSenData],[CompeteData])
	)AS B
	
	SELECT @ReportTitle AS ReportTitle, @ReportImage AS ReportImage,@ClientGuid as ClientGuid
	
	IF @ReportXML IS NOT NULL
		BEGIN
			
			DECLARE @SearchRequestID AS BIGINT,@FromDate AS DATETIME,@ToDate AS DATETIME,@NoofRecordDisplay AS INT
			
			-- Read SearchRequestID from Report XML
			
			SELECT
					@SearchRequestID = c.value('(ID)[1]','BIGINT')
			FROM	@ReportXML.nodes('Report/IQAgent/SearchRequest_Set/SearchRequest') as tbl(c)
			
			-- Read FromDate and ToDate from Report XML
			
			SELECT
					@FromDate = c.value('(StartDate)[1]','DATETIME'),
					@ToDate = c.value('(EndDate)[1]','DATETIME')
			FROM	@ReportXML.nodes('Report/IQAgent/SearchRequest_Set/SearchRequest/Duration') as tbl(c)
			
			
			-- Read various MediaNodes,Type and NoofRecord to display from Report XML
			
			DECLARE @ReportConfig AS TABLE (MediaType VARCHAR(2),NoofRecordToDisplay INT)
			
			INSERT INTO @ReportConfig (MediaType,NoofRecordToDisplay)
			SELECT
					c.value('(Type)[1]','VARCHAR(2)'),
					CASE 
							WHEN @IsSourceEmail = 1 THEN c.value('(NoOfRecordsToDisplayInEmail)[1]','INT')
							ELSE c.value('(NoOfRecordsToDisplay)[1]','INT') 
					END
			FROM
			@ReportXML.nodes('Report/IQAgent/SearchRequest_Set/SearchRequest/Media_Set/Media') as tbl(c)
		
			-- Fetch the records for MediaType='TV'
			
			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TV')
				BEGIN

					DECLARE @TimeZone varchar(50)

					SELECT @TimeZone = Client.TimeZone FROM Client Where ClientGUID = (SELECT ClientGUID FROM IQAgent_SearchRequest WHERE ID = @SearchRequestID)
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TV'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_MediaResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								IQAgent_MediaResults._MediaID,
								
								IQAgent_TVResults.RawMediaThumbUrl,
								IQAgent_TVResults.IQAgentResultUrl,
								IQ_Station.TimeZone as 'TimeZone',
								CONVERT(datetime,CONVERT(varchar(Max),IQAgent_TVResults.RL_Date,101) + ' '+ REPLACE(convert(varchar(Max),convert(decimal(4,2),(convert(decimal(6,2),IQAgent_TVResults.RL_Time)/convert(decimal(5,2),100)))),'.',':')+':00') as 'RL_DateTime',
								case when @NielsenAccess = 1  then Nielsen_Audience else null end as Nielsen_Audience,
								case when @NielsenAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Nielsen_Result,
								RL_Market,
								--RL_Station,
								IQAgent_MediaResults.PositiveSentiment,
								IQAgent_MediaResults.NegativeSentiment
								
					
						FROM IQAgent_MediaResults with (nolock) 

						INNER JOIN IQAgent_TVResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TVResults.ID
						AND		IQAgent_MediaResults.MediaType = 'TV' 
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID						
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
						INNER JOIN IQ_Station with (nolock) 
							ON IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
			
						WHERE	IQAgent_TVResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		IQ_Station.IsActive = 1
					
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS _MediaID,
						
						NULL AS RawMediaThumbUrl,
						NULL AS IQAgentResultUrl,
						NULL as 'TimeZone',
						NULL as 'RL_DateTime',
						NULL as Nielsen_Audience,
						NULL as IQAdShareValue,
						NULL as Nielsen_Result,
						NULL as RL_Market,
						--NULL as RL_Station,
						NULL as PositiveSentiment,
						NULL as NegativeSentiment
				END
			
			
			-- Fetch the records for MediaType='NM'
			
			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'NM')
				BEGIN
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'NM'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_MediaResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_MediaResults.PositiveSentiment,
								IQAgent_MediaResults.NegativeSentiment,
								IQLicense
					
						FROM IQAgent_MediaResults with (nolock) 

						INNER JOIN IQAgent_NMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID
						AND		IQAgent_MediaResults.MediaType = 'NM'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_NMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS Publication,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment,
						null AS IQLicense
				END
				
			-- Fetch the records for MediaType='SM'
			
			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'SM')
				BEGIN
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'SM'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_MediaResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_MediaResults.PositiveSentiment,
								IQAgent_MediaResults.NegativeSentiment
					
						FROM IQAgent_MediaResults with (nolock) 
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID
						AND		IQAgent_MediaResults.MediaType = 'SM'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS homelink,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END
				
			-- Fetch the records for MediaType='TW'
			
			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TW')
				BEGIN
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TW'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_MediaResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_TwitterResults.actor_link,
								IQAgent_TwitterResults.actor_preferredname,
								IQAgent_TwitterResults.actor_displayname,
								IQAgent_TwitterResults.actor_image,
								IQAgent_TwitterResults.gnip_klout_score,
								IQAgent_TwitterResults.actor_followersCount,
								IQAgent_TwitterResults.actor_friendsCount,
								IQAgent_MediaResults.PositiveSentiment,
								IQAgent_MediaResults.NegativeSentiment
					
						FROM IQAgent_MediaResults with (nolock) 
						
						INNER JOIN IQAgent_TwitterResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TwitterResults.ID
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID
						AND		IQAgent_MediaResults.MediaType = 'TW'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_TwitterResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						
						NULL AS	actor_link,
						NULL AS	actor_preferredname,
						NULL AS	actor_displayname,
						NULL AS	actor_image,
						NULL AS	gnip_klout_score,
						NULL AS	actor_followersCount,
						NULL AS	actor_friendsCount,
						NULL AS	PositiveSentiment,
						NULL AS	NegativeSentiment
				END

			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TM')
				BEGIN
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'TM'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_MediaResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								IQAgent_TVEyesResults.StationID,
								IQAgent_TVEyesResults.Market,
								IQAgent_TVEyesResults.DMARank,
								IQAgent_MediaResults.PositiveSentiment,
								IQAgent_MediaResults.NegativeSentiment
					
						FROM IQAgent_MediaResults with (nolock) 
						
						INNER JOIN IQAgent_TVEyesResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TVEyesResults.ID
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID
						AND		IQAgent_MediaResults.MediaType = 'TM'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_TVEyesResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS StationID,
						NULL AS Market,
						NULL AS DMARank,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END

			IF EXISTS(SELECT 1 FROM @ReportConfig AS ReportConfig WHERE MediaType = 'PM')
				BEGIN
					
					SET @NoofRecordDisplay = NULL
					SELECT @NoofRecordDisplay = NoofRecordToDisplay FROM @ReportConfig AS ReportConfig WHERE MediaType = 'PM'
					
					IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
						BEGIN
							SET @NoofRecordDisplay = @MaxDisplayRecord
						END
					
						SELECT 
								TOP(@NoofRecordDisplay)
								IQAgent_MediaResults.ID,
								ISNULL(IQAgent_MediaResults.PositiveSentiment,0) as 'PositiveSentiment' ,
								ISNULL(IQAgent_MediaResults.NegativeSentiment,0) as 'NegativeSentiment',
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.HighlightingText,
								IQAgent_MediaResults.Category,
								IQAgent_MediaResults.MediaDate as 'PubDate',
								IQAgent_BLPMResults.Circulation,
								IQAgent_BLPMResults.FileLocation,
								IQAgent_BLPMResults.Pub_Name
					
						FROM IQAgent_MediaResults with (nolock) 
						
						INNER JOIN IQAgent_BLPMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_BLPMResults.ID
						AND		IQAgent_MediaResults._SearchRequestID = @SearchRequestID
						AND		IQAgent_MediaResults.MediaType = 'PM'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_BLPMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						
						ORDER BY IQAgent_MediaResults.ID DESC
							
				END
			ELSE
				BEGIN
					SELECT 
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS StationID,
						NULL AS Market,
						NULL AS DMARank,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END
			
		END
	

END