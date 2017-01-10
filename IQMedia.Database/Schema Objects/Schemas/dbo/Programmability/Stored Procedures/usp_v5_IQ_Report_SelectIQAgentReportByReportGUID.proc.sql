CREATE PROCEDURE [dbo].[usp_v5_IQ_Report_SelectIQAgentReportByReportGUID]
	@ReportGUID			UNIQUEIDENTIFIER,
	@MaxDisplayRecord	INT,
	@SearchRequestID	BIGINT,
	@MediaType			Varchar(15),
	@IsSourceEmail		BIT,
	@UseRollup			BIT=0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ReportType VARCHAR(16), @ReportRule XML

	SELECT	
			@ReportType = IQ_ReportType.[Identity],
			@ReportRule=IQ_Report.ReportRule
	FROM	
			IQ_Report 
				INNER JOIN	IQ_ReportType
					ON	IQ_Report._ReportTypeID = IQ_ReportType.ID
	WHERE
			ReportGUID=@ReportGUID
		AND	IQ_Report.IsActive = 1
		--AND IQ_ReportType.IsActive=1 hourly notification format is changed, introduce new report type made old type to inactive. So to keep working already sent notification with old format.

	IF (@ReportType='HOURLY' AND @ReportRule.exist('Report/IQAgent/SearchRequestIDList/SearchRequestID/Results')=1)
		BEGIN			
			EXEC usp_v5_IQ_Report_SelectIQAgentReportByReportGUID_Hourly @ReportGUID,@MaxDisplayRecord,@SearchRequestID,@MediaType,@IsSourceEmail,@UseRollup OUTPUT

		END																			 			
	ELSE																			 		
		BEGIN		
		

		DECLARE @ReportXML AS XML,@ReportTitle AS VARCHAR(500),@ReportImage varchar(255),@ClientGuid UNIQUEIDENTIFIER, @NoofRecordDisplay int,@FromDate datetime,@ToDate datetime
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
			AND IQClient_CustomImage.IsDefaultEmail = 1 AND IQClient_CustomImage.IsActive = 1
		WHERE (
			IQ_ReportType.[Identity] = 'OnceDay'
		OR  IQ_ReportType.[Identity] = 'OnceWeek'
		OR IQ_ReportType.[Identity] = 'Hourly'
	
		) 
		AND ReportGUID = @ReportGUID
		AND		IQ_Report.IsActive = 1
		--AND		IQ_ReportType.IsActive = 1

		Select
				@UseRollup=UseRollup
		From
				IQNotificationSettings
					Inner join	IQNotificationTracking
						on	IQNotificationSettings.IQNotificationKey=IQNotificationTracking._SettingsID		
						and	ReportGUID=@ReportGUID				
	
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

		DECLARE @TimeZone varchar(50)
		SELECT @TimeZone = Client.TimeZone FROM Client Where ClientGUID = @ClientGuid		
	
		IF OBJECT_ID('tempdb..#TblSearchRequest') IS NOT NULL
			DROP TABLE #TblSearchRequest

		IF OBJECT_ID('tempdb..#TblMediaTypes') IS NOT NULL
			DROP TABLE #TblMediaTypes

		CREATE TABLE #TblSearchRequest (SearchRequestID bigint)		
		CREATE TABLE #TblMediaTypes (MediaType VARCHAR(15))	
			
		IF @ReportXML IS NOT NULL
		BEGIN

			INSERT INTO #TblSearchRequest
			(
				SearchRequestID
			)
			SELECT 
						c.value('.','BIGINT') as SearchRequestID
			FROM	
				@ReportXML.nodes('Report/IQAgent/SearchRequestIDList/ID') as tbl(c)
			WHERe
				(@SearchRequestID IS NULL OR c.value('.','BIGINT') = @SearchRequestID)
				
			INSERT INTO #TblMediaTypes (MediaType)
			SELECT
					c.value('.','VARCHAR(15)')
			FROM
					@ReportXML.nodes('Report/IQAgent/MediaList/Type') as tbl(c)
			WHERE
				(@MediaType IS NULL OR c.value('.','VARCHAR(15)') = @MediaType)

		
			SELECT 
					@NoofRecordDisplay = CASE WHEN @IsSourceEmail = 1 THEN c.value('(NoOfRecordsToDisplayInEmail)[1]','INT') ELSE c.value('(NoOfRecordsToDisplay)[1]','INT') END,
					@FromDate = c.value('(Duration/StartDate)[1]','DATETIME'),
					@ToDate = c.value('(Duration/EndDate)[1]','DATETIME')
			FROM 
					@ReportXML.nodes('Report/IQAgent') as tbl(c)
					
					
			--IF @NoofRecordDisplay IS NULL OR @NoofRecordDisplay = 0
			--BEGIN
			--	SET @NoofRecordDisplay = @MaxDisplayRecord
			--END
			SET @NoofRecordDisplay = 500
				
		END	
	
		SELECT @ReportTitle AS ReportTitle, @ReportImage AS ReportImage,@ClientGuid as ClientGuid
	
			
		If EXISTS(SELECT 1 FROM #TblSearchRequest)
		BEGIN
				
			SELECT distinct
				rsettings.SearchRequestID,
				IQAgent_SearchRequest.Query_Name
			FROM
				#TblSearchRequest as rsettings 
					INNER JOIN IQAgent_SearchRequest 
						ON rsettings.SearchRequestID = IQAgent_SearchRequest .ID
						and ClientGUID = @ClientGuid
			ORDER BY rsettings.SearchRequestID asc

						
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'TV')
				BEGIN				
					if(@UseRollup!=1)	
					begin
						;With TempTV AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_TVResults.CC_Highlight as HighlightingText,
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_MediaResults._MediaID,
								
								IQAgent_TVResults.RawMediaThumbUrl,
								IQAgent_TVResults.IQAgentResultUrl,
								IQ_Station.TimeZone as 'TimeZone',
								RL_Date as LocalDate,
								RL_Time as LocalTime,
								case when @NielsenAccess = 1  then Nielsen_Audience else null end as Nielsen_Audience,
								case when @NielsenAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Nielsen_Result,
								RL_Market as Market,
								--RL_Station,
								IQAgent_TVResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_TVResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
								
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID

						INNER JOIN IQAgent_TVResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TVResults.ID
						AND	IQAgent_MediaResults.v5Category = IQAgent_TVResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'TV' 
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
						INNER JOIN IQ_Station with (nolock) 
							ON IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
			
						WHERE	IQAgent_TVResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		IQ_Station.IsActive = 1
						)
				
						SELECT * FROM TempTV where RowNum  > 0 and RowNum <= @NoofRecordDisplay
					end
					else
					begin
						
						declare @TVTbl table(RowNum int, ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime, 
										HighlightingText xml, Category varchar(50), _MediaID bigint, 
										RawMediaThumbUrl varchar(255), IQAgentResultUrl varchar(255), TimeZone char(3),
										LocalDate date, LocalTime int, Nielsen_Audience int, IQAdShareValue float,
										Nielsen_Result char(1), Market varchar(150), PositiveSentiment tinyint, 
										NegativeSentiment tinyint, ParentID bigint)

						declare @ParentTVTbl table(ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime, 
										HighlightingText xml, Category varchar(50), _MediaID bigint, 
										RawMediaThumbUrl varchar(255), IQAgentResultUrl varchar(255), TimeZone char(3),
										LocalDate date, LocalTime int, Nielsen_Audience int, IQAdShareValue float,
										Nielsen_Result char(1), Market varchar(150), PositiveSentiment tinyint, 
										NegativeSentiment tinyint, ParentID bigint)

						Insert into @TVTbl
						(
							RowNum,						
							SearchRequestID,
							ID, 
							Title,
							MediaDate, 
							HighlightingText,
							Category,
							_MediaID, 
							RawMediaThumbUrl,
							IQAgentResultUrl,
							TimeZone,
							LocalDate,
							LocalTime,
							Nielsen_Audience,
							IQAdShareValue,
							Nielsen_Result,
							Market,
							PositiveSentiment, 
							NegativeSentiment,
							ParentID
						)
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY _ParentID ASC, MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_TVResults.CC_Highlight as HighlightingText,
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_MediaResults._MediaID,
								
								IQAgent_TVResults.RawMediaThumbUrl,
								IQAgent_TVResults.IQAgentResultUrl,
								IQ_Station.TimeZone as 'TimeZone',
								RL_Date as LocalDate,
								RL_Time as LocalTime,
								case when @NielsenAccess = 1  then Nielsen_Audience else null end as Nielsen_Audience,
								case when @NielsenAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Nielsen_Result,
								RL_Market as Market,
								--RL_Station,
								IQAgent_TVResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_TVResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								_ParentID
					
						FROM 
								IQAgent_SearchRequest with (nolock) 
										INNER JOIN	IQAgent_MediaResults with (nolock) 
											ON	IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
											AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
										INNER JOIN	#TblSearchRequest as rsettings 
											ON	rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
										INNER JOIN	IQAgent_TVResults with (nolock) 
											ON	IQAgent_MediaResults._MediaID =  IQAgent_TVResults.ID
											AND	IQAgent_MediaResults.v5Category = IQAgent_TVResults.v5SubMediaType
											AND	IQAgent_MediaResults.v5Category = 'TV' 
											AND	IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
										INNER JOIN	IQ_Station with (nolock) 
											ON	IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
			
						WHERE
								IQAgent_TVResults.IsActive = 1
							AND	IQAgent_MediaResults.IsActive = 1
							AND	IQ_Station.IsActive = 1

						Insert into @ParentTVTbl
						(
							ID, 
							SearchRequestID,
							Title,
							MediaDate, 
							HighlightingText,
							Category,
							_MediaID, 
							RawMediaThumbUrl,
							IQAgentResultUrl,
							TimeZone,
							LocalDate,
							LocalTime,
							Nielsen_Audience,
							IQAdShareValue,
							Nielsen_Result,
							Market,
							PositiveSentiment, 
							NegativeSentiment,
							ParentID
						)
						Select							
								ID, 
								SearchRequestID,
								Title,
								MediaDate, 
								HighlightingText,
								Category,
								_MediaID, 
								RawMediaThumbUrl,
								IQAgentResultUrl,
								TimeZone,
								LocalDate,
								LocalTime,
								Nielsen_Audience,
								IQAdShareValue,
								Nielsen_Result,
								Market,
								PositiveSentiment, 
								NegativeSentiment,
								ParentID
						From
								@TVTbl
						where 
								RowNum between 1 and @NoofRecordDisplay
							and ParentID is null


						Select
								ID, 
								SearchRequestID,
								Title,
								MediaDate, 
								HighlightingText,
								Category,
								_MediaID, 
								RawMediaThumbUrl,
								IQAgentResultUrl,
								TimeZone,
								LocalDate,
								LocalTime,
								Nielsen_Audience,
								IQAdShareValue,
								Nielsen_Result,
								Market,
								PositiveSentiment, 
								NegativeSentiment,
								ParentID
						From
								@ParentTVTbl

						Union all

						Select
								TVTbl.ID, 
								TVTbl.SearchRequestID,
								TVTbl.Title,
								TVTbl.MediaDate, 
								TVTbl.HighlightingText,
								TVTbl.Category,
								TVTbl._MediaID, 
								TVTbl.RawMediaThumbUrl,
								TVTbl.IQAgentResultUrl,
								TVTbl.TimeZone,
								TVTbl.LocalDate,
								TVTbl.LocalTime,
								TVTbl.Nielsen_Audience,
								TVTbl.IQAdShareValue,
								TVTbl.Nielsen_Result,
								TVTbl.Market,
								TVTbl.PositiveSentiment, 
								TVTbl.NegativeSentiment,
								TVTbl.ParentID
						From
								@TVTbl as TVTbl
										inner join	@ParentTVTbl as ParentTVTbl
											on	TVTbl.ParentID=ParentTVTbl.ID			

					end
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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
			
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'NM')
				BEGIN
					if(@UseRollup!=1)
					begin
						;With TempNM AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_NMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_NMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_NMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								IQLicense
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid


						INNER JOIN IQAgent_NMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'NM'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_NMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempNM where RowNum  > 0 and RowNum <= @NoofRecordDisplay
					end
					else
					begin
						
						declare @NMTbl table (RowNum int, ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime,
										 HighlightingText xml, Category varchar(50), Url varchar(max), Compete_Audience int,
										 IQAdShareValue float, Compete_Result char(1), Publication varchar(255), 
										 PositiveSentiment tinyint, NegativeSentiment tinyint, IQLicense tinyint,ParentID bigint)

						declare @ParentNMTbl table (ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime,
										 HighlightingText xml, Category varchar(50), Url varchar(max), Compete_Audience int,
										 IQAdShareValue float, Compete_Result char(1), Publication varchar(255), 
										 PositiveSentiment tinyint, NegativeSentiment tinyint, IQLicense tinyint,ParentID bigint) 

						insert into @NMTbl
						(
							RowNum,
							SearchRequestID,
							ID,
							Title,
							MediaDate,
							HighlightingText,
							Category,
							Url,
							Compete_Audience,
							Compete_Result,
							IQAdShareValue,
							Publication,
							PositiveSentiment,
							NegativeSentiment,
							IQLicense,
							ParentID
						)
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY _ParentID ASC, MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_NMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_NMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_NMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								IQLicense,
								_ParentID
													
						FROM 
								IQAgent_SearchRequest with (nolock) 
										INNER JOIN	IQAgent_MediaResults with (nolock) 
											ON	IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
										INNER JOIN	#TblSearchRequest as rsettings 
											ON	rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
											AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
										INNER JOIN	IQAgent_NMResults with (nolock) 
											ON	IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID
											AND	IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
											AND	IQAgent_MediaResults.v5Category = 'NM'
											AND	IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE
								IQAgent_NMResults.IsActive = 1
							AND	IQAgent_MediaResults.IsActive = 1


						insert into @ParentNMTbl
						(
							SearchRequestID,
							ID,
							Title,
							MediaDate,
							HighlightingText,
							Category,
							Url,
							Compete_Audience,
							Compete_Result,
							IQAdShareValue,
							Publication,
							PositiveSentiment,
							NegativeSentiment,
							IQLicense,
							ParentID
						)
						SELECT							
								SearchRequestID,
								ID,
								Title,
								MediaDate,
								HighlightingText,
								Category,
								Url,
								Compete_Audience,
								Compete_Result,
								IQAdShareValue,
								Publication,
								PositiveSentiment,
								NegativeSentiment,
								IQLicense,
								ParentID
						FROM 
								@NMTbl
						where 
								rownum between 1 and @NoofRecordDisplay
							and ParentID is null


						Select
								SearchRequestID,
								ID,
								Title,
								MediaDate,
								HighlightingText,
								Category,
								Url,
								Compete_Audience,
								Compete_Result,
								IQAdShareValue,
								Publication,
								PositiveSentiment,
								NegativeSentiment,
								IQLicense,
								NULL as ParentID
						From
								@ParentNMTbl

						Union all

						Select
								NMTbl.SearchRequestID,
								NMTbl.ID,
								NMTbl.Title,
								NMTbl.MediaDate,
								NMTbl.HighlightingText,
								NMTbl.Category,
								NMTbl.Url,
								NMTbl.Compete_Audience,
								NMTbl.Compete_Result,
								NMTbl.IQAdShareValue,
								NMTbl.Publication,
								NMTbl.PositiveSentiment,
								NMTbl.NegativeSentiment,
								NMTbl.IQLicense,
								NMTbl.ParentID
						From
								@NMTbl as NMTbl
										inner join	@ParentNMTbl as ParentNMTbl
											on	NMTbl.ParentID=ParentNMTbl.ID

					end
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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
			
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'SocialMedia')
				BEGIN
					;With TempSocialMedia AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.[ArticleStats],
                                IQAgent_SMResults.ThumbUrl,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'SocialMedia'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempSocialMedia where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS ArticleStats,
						NULL AS ThumbUrl,
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS homelink,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'FB')
				BEGIN
					;With TempFB AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.[ArticleStats],
                                IQAgent_SMResults.ThumbUrl,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND	IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'FB'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempFB where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS ArticleStats,
						NULL AS ThumbUrl,
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS homelink,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'IG')
				BEGIN
					;With TempIG AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.[ArticleStats],
                                IQAgent_SMResults.ThumbUrl,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'IG'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempIG where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						NULL AS ArticleStats,
						NULL AS ThumbUrl,
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS homelink,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END
				
				
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'Blog')
				BEGIN
					;With TempBlog AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'Blog'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)
					SELECT * FROM TempBlog where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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
				
				
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'Forum')
				BEGIN
					;With TempForum AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_SMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_SMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'Forum'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempForum where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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
			
			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'TW')
				BEGIN
					;With TempTW AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_TwitterResults.HighlightingText,	
								IQAgent_MediaResults.v5Category AS Category,
								
								IQAgent_TwitterResults.TweetID,
								IQAgent_TwitterResults.actor_link,
								IQAgent_TwitterResults.actor_preferredname,
								IQAgent_TwitterResults.actor_displayname,
								IQAgent_TwitterResults.actor_image,
								IQAgent_TwitterResults.gnip_klout_score,
								IQAgent_TwitterResults.actor_followersCount,
								IQAgent_TwitterResults.actor_friendsCount,
								IQAgent_TwitterResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_TwitterResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
						INNER JOIN IQAgent_TwitterResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TwitterResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_TwitterResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'TW'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_TwitterResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1		
					)
					SELECT * FROM TempTW where RowNum  > 0 and RowNum <= @NoofRecordDisplay

				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL AS ID,
						NULL AS Title,
						NULL AS MediaDate,
						NULL AS HighlightingText,					
						NULL AS Category,
						
						NULL AS TweetID,
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

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'Radio')
				BEGIN
					;With TempTM AS(
						SELECT 
									ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
									rsettings.SearchRequestID,
									IQAgent_MediaResults.ID,
									IQAgent_MediaResults.Title,
									IQAgent_MediaResults.MediaDate,
									IQAgent_TVEyesResults.CC_Highlight as HighlightingText,					
									IQAgent_MediaResults.v5Category AS Category,
									IQAgent_TVEyesResults.StationID,
									IQAgent_TVEyesResults.Market,
									IQAgent_TVEyesResults.DMARank,
									IQAgent_TVEyesResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
									IQAgent_TVEyesResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
							FROM IQAgent_SearchRequest with (nolock) 
									INNER JOIN IQAgent_MediaResults with (nolock) 
										ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
									INNER JOIN #TblSearchRequest as rsettings 
										ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
							INNER JOIN IQAgent_TVEyesResults with (nolock) 
							ON		IQAgent_MediaResults._MediaID =  IQAgent_TVEyesResults.ID
							AND		IQAgent_MediaResults.v5Category = IQAgent_TVEyesResults.v5SubMediaType
							AND		IQAgent_MediaResults.v5Category = 'Radio'
							AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
							WHERE	IQAgent_TVEyesResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
						)	
						SELECT * FROM TempTM where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'PM')
				BEGIN
					;With TempPM AS(
						SELECT 
									ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY IQAgent_BLPMResults.CreatedDate DESC) As RowNum,
									rsettings.SearchRequestID,
									IQAgent_MediaResults.ID,
									ISNULL(IQAgent_MediaResults.PositiveSentiment,0) as 'PositiveSentiment' ,
									ISNULL(IQAgent_MediaResults.NegativeSentiment,0) as 'NegativeSentiment',
									IQAgent_MediaResults.Title,
									IQAgent_BLPMResults.BLPMXml as HighlightingText,
									IQAgent_MediaResults.v5Category AS Category,
									IQAgent_MediaResults.MediaDate as 'PubDate',
									IQAgent_BLPMResults.Circulation,
									IQAgent_BLPMResults.FileLocation,
									IQAgent_BLPMResults.Pub_Name
					
							FROM IQAgent_SearchRequest with (nolock) 
									INNER JOIN IQAgent_MediaResults with (nolock) 
										ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
									INNER JOIN #TblSearchRequest as rsettings
										ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
							INNER JOIN IQAgent_BLPMResults with (nolock) 
							ON		IQAgent_MediaResults._MediaID =  IQAgent_BLPMResults.ID
							AND		IQAgent_MediaResults.v5Category = IQAgent_BLPMResults.v5SubMediaType
							AND		IQAgent_MediaResults.v5Category = 'PM'
							AND		DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), IQAgent_BLPMResults.CreatedDate) BETWEEN @FromDate AND @ToDate
			
							WHERE	IQAgent_BLPMResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
						)		
						SELECT * FROM TempPM where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL as ID,
						NULL as 'PositiveSentiment' ,
						NULL as 'NegativeSentiment',
						NULL as Title,
						NULL as HighlightingText,
						NULL as Category,
						NULL as 'PubDate',
						NULL as Circulation,
						NULL as FileLocation,
						NULL as Pub_Name
				END

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'PQ')
				BEGIN
					;With TempPQ AS(
						SELECT 
									ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY IQAgent_PQResults.CreatedDate DESC) As RowNum,
									rsettings.SearchRequestID,
									IQAgent_MediaResults.ID,									
									IQAgent_MediaResults.Title,
									IQAgent_PQResults.HighlightingText,
									IQAgent_MediaResults.v5Category AS Category,
									IQAgent_PQResults.MediaDate,
									IQAgent_PQResults.Publication,
									IQAgent_PQResults.Authors,									
									IQAgent_PQResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
									IQAgent_PQResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
							FROM IQAgent_SearchRequest with (nolock) 
									INNER JOIN IQAgent_MediaResults with (nolock) 
										ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
									INNER JOIN #TblSearchRequest as rsettings
										ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
										AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
						
							INNER JOIN IQAgent_PQResults with (nolock) 
							ON		IQAgent_MediaResults._MediaID =  IQAgent_PQResults.ID
							AND		IQAgent_MediaResults.v5Category = IQAgent_PQResults.v5SubMediaType
							AND		IQAgent_MediaResults.v5Category = 'PQ'
							AND		DATEADD(mi, DATEDIFF(mi, GETDATE(), GETUTCDATE()), IQAgent_PQResults.CreatedDate) BETWEEN @FromDate AND @ToDate
			
							WHERE	IQAgent_PQResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
						)		
						SELECT * FROM TempPQ where RowNum  > 0 and RowNum <= @NoofRecordDisplay
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
						NULL as ID,						
						NULL as Title,
						NULL as HighlightingText,
						NULL as Category,
						NULL as MediaDate,
						NULL as Publication,
						NULL as Authors,
						NULL as PositiveSentiment,
						NULL as NegativeSentiment
						
				END

			IF EXISTS(SELECT 1 FROM #TblMediaTypes AS ReportConfig WHERE MediaType = 'LN')
				BEGIN
					if(@UseRollup!=1)
					begin
						;With TempLN AS(
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_NMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_NMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_NMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								IQLicense
					
						FROM IQAgent_SearchRequest with (nolock) 
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
								INNER JOIN #TblSearchRequest as rsettings 
									ON rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
									AND IQAgent_SearchRequest.ClientGuid = @ClientGuid


						INNER JOIN IQAgent_NMResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID
						AND		IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
						AND		IQAgent_MediaResults.v5Category = 'LN'
						AND		IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE	IQAgent_NMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
					)		
					SELECT * FROM TempLN where RowNum  > 0 and RowNum <= @NoofRecordDisplay
					end
					else
					begin
						
						declare @LNTbl table (RowNum int, ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime,
										 HighlightingText xml, Category varchar(50), Url varchar(max), Compete_Audience int,
										 IQAdShareValue float, Compete_Result char(1), Publication varchar(255), 
										 PositiveSentiment tinyint, NegativeSentiment tinyint, IQLicense tinyint,ParentID bigint)

						declare @ParentLNTbl table (ID bigint, SearchRequestID bigint, Title varchar(512), MediaDate datetime,
										 HighlightingText xml, Category varchar(50), Url varchar(max), Compete_Audience int,
										 IQAdShareValue float, Compete_Result char(1), Publication varchar(255), 
										 PositiveSentiment tinyint, NegativeSentiment tinyint, IQLicense tinyint,ParentID bigint) 

						insert into @LNTbl
						(
							RowNum,
							SearchRequestID,
							ID,
							Title,
							MediaDate,
							HighlightingText,
							Category,
							Url,
							Compete_Audience,
							Compete_Result,
							IQAdShareValue,
							Publication,
							PositiveSentiment,
							NegativeSentiment,
							IQLicense,
							ParentID
						)
						SELECT 
								ROW_NUMBER() OVER (PARTITION BY IQAgent_SearchRequest.ID ORDER BY _ParentID ASC, MediaDate DESC) As RowNum,
								rsettings.SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_NMResults.HighlightingText,						
								IQAgent_MediaResults.v5Category AS Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_NMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_NMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								IQLicense,
								_ParentID
													
						FROM 
								IQAgent_SearchRequest with (nolock) 
										INNER JOIN	IQAgent_MediaResults with (nolock) 
											ON	IQAgent_SearchRequest.ID  = IQAgent_MediaResults._SearchRequestID
										INNER JOIN	#TblSearchRequest as rsettings 
											ON	rsettings.SearchRequestID  = IQAgent_SearchRequest.ID
											AND IQAgent_SearchRequest.ClientGuid = @ClientGuid
										INNER JOIN	IQAgent_NMResults with (nolock) 
											ON	IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID
											AND	IQAgent_MediaResults.v5Category = IQAgent_NMResults.v5SubMediaType
											AND	IQAgent_MediaResults.v5Category = 'LN'
											AND	IQAgent_MediaResults.MediaDate BETWEEN @FromDate AND @ToDate
			
						WHERE
								IQAgent_NMResults.IsActive = 1
							AND	IQAgent_MediaResults.IsActive = 1


						insert into @ParentLNTbl
						(
							SearchRequestID,
							ID,
							Title,
							MediaDate,
							HighlightingText,
							Category,
							Url,
							Compete_Audience,
							Compete_Result,
							IQAdShareValue,
							Publication,
							PositiveSentiment,
							NegativeSentiment,
							IQLicense,
							ParentID
						)
						SELECT							
								SearchRequestID,
								ID,
								Title,
								MediaDate,
								HighlightingText,
								Category,
								Url,
								Compete_Audience,
								Compete_Result,
								IQAdShareValue,
								Publication,
								PositiveSentiment,
								NegativeSentiment,
								IQLicense,
								ParentID
						FROM 
								@LNTbl
						where 
								rownum between 1 and @NoofRecordDisplay
							and ParentID is null


						Select
								SearchRequestID,
								ID,
								Title,
								MediaDate,
								HighlightingText,
								Category,
								Url,
								Compete_Audience,
								Compete_Result,
								IQAdShareValue,
								Publication,
								PositiveSentiment,
								NegativeSentiment,
								IQLicense,
								NULL as ParentID
						From
								@ParentLNTbl

						Union all

						Select
								LNTbl.SearchRequestID,
								LNTbl.ID,
								LNTbl.Title,
								LNTbl.MediaDate,
								LNTbl.HighlightingText,
								LNTbl.Category,
								LNTbl.Url,
								LNTbl.Compete_Audience,
								LNTbl.Compete_Result,
								LNTbl.IQAdShareValue,
								LNTbl.Publication,
								LNTbl.PositiveSentiment,
								LNTbl.NegativeSentiment,
								LNTbl.IQLicense,
								LNTbl.ParentID
						From
								@LNTbl as LNTbl
										inner join	@ParentLNTbl as ParentLNTbl
											on	LNTbl.ParentID=ParentLNTbl.ID

					end
				END
			ELSE
				BEGIN
					SELECT 
						NULL as SearchRequestID,
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


			END
		END
END