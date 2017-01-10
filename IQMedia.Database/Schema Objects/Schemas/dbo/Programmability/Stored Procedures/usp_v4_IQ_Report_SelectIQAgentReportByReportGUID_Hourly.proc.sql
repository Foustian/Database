CREATE PROCEDURE [dbo].[usp_v4_IQ_Report_SelectIQAgentReportByReportGUID_Hourly]
(
	@ReportGUID			UNIQUEIDENTIFIER,
	@MaxDisplayRecord	INT,
	@SearchRequestID	BIGINT,
	@MediaType			Varchar(15),
	@IsSourceEmail		BIT,
	@UseRollup			BIT=0 OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	

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
		WHERE 
				IQ_ReportType.[Identity] = 'Hourly'		
			AND ReportGUID = @ReportGUID
			AND	IQ_Report.IsActive = 1
			AND	IQ_ReportType.IsActive = 1

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
	
		IF OBJECT_ID('tempdb..#TblMedia') IS NOT NULL
			BEGIN
				DROP TABLE #TblMedia
			END

		IF OBJECT_ID('tempdb..#TblSearchRequest') IS NOT NULL
			BEGIN
				DROP TABLE #TblSearchRequest
			END

		CREATE TABLE #TblMedia (ID BIGINT,SRID BIGINT, SubMediaType	VARCHAR(12))		
		CREATE TABLE #TblSearchRequest (ID BIGINT,QueryName Varchar(255))		

		Declare @TVXml	XML,
				@NMXml	XML,
				@BlogXml	XML,
				@ForumXml	XML,
				@SMXml	XML,
				@TWXml	XML,
				@TMXml	XML,
				@PMXml	XML,
				@PQXml	XML
			
		IF @ReportXML IS NOT NULL
		BEGIN
	
			SET @NoofRecordDisplay = 500

			select @TVXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/TV/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="TV"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@TVXml.nodes('Media') as tbl(c)

			select @NMXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/NM/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="NM"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@NMXml.nodes('Media') as tbl(c)

			select @BlogXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/Blog/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="Blog"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@BlogXml.nodes('Media') as tbl(c)

			select @ForumXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/Forum/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="Forum"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@ForumXml.nodes('Media') as tbl(c)

			select @SMXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/SocialMedia/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="SocialMedia"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@SMXml.nodes('Media') as tbl(c)

			select @TWXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/TW/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="TW"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@TWXml.nodes('Media') as tbl(c)

			select @TMXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/TM/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="TM"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@TMXml.nodes('Media') as tbl(c)

			select @PMXml=@ReportXML.query('
									for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
										 $SRID in $SR/ID,
										$ID in $SR/Results/PM/ID	   
									return        		
										<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="PM"></Media>
								')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@PMXml.nodes('Media') as tbl(c)

			Select @PQXml=@ReportXML.query('
							for $SR in /Report/IQAgent/SearchRequestIDList/SearchRequestID,
									$SRID in $SR/ID,
								$ID in $SR/Results/PQ/ID	   
							return        		
								<Media SRID="{$SRID}" ID="{$ID}" SubMediaType="PQ"></Media>
						')

			INSERT INTO #TblMedia
			(
				ID,
				SRID,
				SubMediaType
			)
			Select
					tbl.c.value('@ID','bigint'),
					tbl.c.value('@SRID','bigint'),
					tbl.c.value('@SubMediaType','varchar(12)')
			From
					@PQXml.nodes('Media') as tbl(c)

			insert into #TblSearchRequest
			(
				ID,
				QueryName
			)
			Select
					distinct 
					TblMedia.SRID,
					IQAgent_SearchRequest.Query_Name
			From
					#TblMedia as TblMedia
					INNER JOIN IQAgent_SearchRequest 
						ON TblMedia.SRID = IQAgent_SearchRequest .ID
						and ClientGUID = @ClientGuid
				
		END	
	
		SELECT @ReportTitle AS ReportTitle, @ReportImage AS ReportImage,@ClientGuid as ClientGuid
	
			
		If EXISTS(SELECT 1 FROM #TblMedia)
		BEGIN
				
			SELECT 
					ID as SearchRequestID,
					QueryName as Query_Name
			from
					#TblSearchRequest as TblSearchRequest
			Order by
					TblSearchRequest.ID asc

						
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'TV')
				BEGIN					

					Select 
							TVResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_TVResults.CC_Highlight as HighlightingText,					
								IQAgent_MediaResults.Category,
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
								_ParentID as ParentID
					
						FROM 
								#TblMedia as TblMedia									
									INNER JOIN IQAgent_TVResults with (nolock)
										ON TblMedia.ID=IQAgent_TVResults.ID
										AND		TblMedia.SubMediaType = 'TV' 
									INNER JOIN IQAgent_MediaResults with (nolock) 			
										ON		IQAgent_MediaResults._MediaID =  IQAgent_TVResults.ID						
										AND IQAgent_MediaResults.MediaType='TV'
									INNER JOIN IQ_Station with (nolock) 
										ON IQAgent_TVResults.RL_Station = IQ_Station.IQ_Station_ID
			
						WHERE	IQAgent_TVResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		IQ_Station.IsActive = 1
						AND		TblMedia.SRID=TblSearchRequest.ID					
						

					) as TVResults				

					Order by TVResults.MediaDate desc

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
			
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'NM')
				BEGIN

					Select 
							NMResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_NMResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								IQAgent_NMResults.Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								Publication,
								IQAgent_NMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_NMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment,
								IQLicense,
								_ParentID as ParentID
					
						FROM #TblMedia as TblMedia
								INNER JOIN IQAgent_NMResults with (nolock) 
									ON TblMedia.ID  = IQAgent_NMResults.ID
									AND		TblMedia.SubMediaType = 'NM'	
								INNER JOIN IQAgent_MediaResults with (nolock) 
									ON	IQAgent_MediaResults._MediaID =  IQAgent_NMResults.ID						
									AND IQAgent_MediaResults.MediaType='NM'
						WHERE	IQAgent_NMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		TblMedia.SRID=TblSearchRequest.ID						

					) as NMResults		

					Order by NMResults.MediaDate desc

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
			
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'SocialMedia')
				BEGIN
					Select 
							SMResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								Top(@NoofRecordDisplay)
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.[ArticleStats],
                                IQAgent_SMResults.ThumbUrl,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM	#TblMedia as TblMedia
									INNER JOIN IQAgent_SMResults with (nolock)
									ON TblMedia.ID  = IQAgent_SMResults.ID
									AND		TblMedia.SubMediaType = 'SocialMedia'							
									INNER JOIN IQAgent_MediaResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID									
								AND IQAgent_MediaResults.Category='SocialMedia' 
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		TblMedia.SRID=TblSearchRequest.ID

						Order by MediaDate desc

					) as SMResults		
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
						NULL AS ThumbUrl,
                        NULL AS ArticleStats,
						NULL AS Url,
						NULL AS Compete_Audience,
						NULL AS IQAdShareValue,
						NULL AS Compete_Result,
						NULL AS homelink,
						NULL AS PositiveSentiment,
						NULL AS NegativeSentiment
				END
				
				
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'Blog')
				BEGIN
					Select 
							BlogResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								Top(@NoofRecordDisplay)
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM #TblMedia as TblMedia
								INNER JOIN IQAgent_SMResults with (nolock)
									ON TblMedia.ID  = IQAgent_SMResults.ID
									AND		TblMedia.SubMediaType = 'Blog'							
									INNER JOIN IQAgent_MediaResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID									
								AND IQAgent_MediaResults.Category='Blog' 
						
						
			
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		TblMedia.SRID=TblSearchRequest.ID

						order by MediaDate desc
					) as BlogResults
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
				
				
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'Forum')
				BEGIN
					Select 
							ForumResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								Top(@NoofRecordDisplay)
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_SMResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_SMResults.Link AS Url,
								case when @CompeteAccess = 1  then Compete_Audience else null end as Compete_Audience,
								case when @CompeteAccess = 1  then Compete_Result else null end as Compete_Result,
								case when @CompeteAccess = 1  then IQAdShareValue else null end as IQAdShareValue,
								homelink,
								IQAgent_SMResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_SMResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM	#TblMedia as TblMedia
									INNER JOIN IQAgent_SMResults with (nolock)
									ON TblMedia.ID  = IQAgent_SMResults.ID
									AND		TblMedia.SubMediaType = 'Forum'							
									INNER JOIN IQAgent_MediaResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_SMResults.ID									
								AND IQAgent_MediaResults.Category='Forum' 
									
						WHERE	IQAgent_SMResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1
						AND		TblMedia.SRID=TblSearchRequest.ID

						Order by MediaDate desc
					) as ForumResults		
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
			
			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'TW')
				BEGIN
					Select 
							TWResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
								Top(@NoofRecordDisplay)
								TblMedia.SRID as SearchRequestID,
								IQAgent_MediaResults.ID,
								IQAgent_MediaResults.Title,
								IQAgent_MediaResults.MediaDate,
								IQAgent_TwitterResults.HighlightingText,					
								IQAgent_MediaResults.Category,
								
								IQAgent_TwitterResults.actor_link,
								IQAgent_TwitterResults.actor_preferredname,
								IQAgent_TwitterResults.actor_displayname,
								IQAgent_TwitterResults.actor_image,
								IQAgent_TwitterResults.gnip_klout_score,
								IQAgent_TwitterResults.actor_followersCount,
								IQAgent_TwitterResults.actor_friendsCount,
								IQAgent_TwitterResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
								IQAgent_TwitterResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
						FROM	#TblMedia as TblMedia
								INNER JOIN IQAgent_TwitterResults with (nolock) 
								ON TblMedia.ID  = IQAgent_TwitterResults.ID
									AND	TblMedia.SubMediaType = 'TW'
									INNER JOIN IQAgent_MediaResults with (nolock) 
						ON		IQAgent_MediaResults._MediaID =  IQAgent_TwitterResults.ID
								AND IQAgent_MediaResults.MediaType='TW' 
						WHERE	IQAgent_TwitterResults.IsActive = 1
						AND		IQAgent_MediaResults.IsActive = 1		
						AND		TblMedia.SRID=TblSearchRequest.ID

						order by MediaDate desc
					) as TWResults

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

			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType ='TM')
				BEGIN
					Select 
							TMResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
									Top(@NoofRecordDisplay)
									TblMedia.SRID as SearchRequestID,
									IQAgent_MediaResults.ID,
									IQAgent_MediaResults.Title,
									IQAgent_MediaResults.MediaDate,
									IQAgent_TVEyesResults.CC_Highlight as HighlightingText,					
									IQAgent_MediaResults.Category,
									IQAgent_TVEyesResults.StationID,
									IQAgent_TVEyesResults.Market,
									IQAgent_TVEyesResults.DMARank,
									IQAgent_TVEyesResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
									IQAgent_TVEyesResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
							FROM #TblMedia as TblMedia
									INNER JOIN IQAgent_TVEyesResults with (nolock)
									ON TblMedia.ID  = IQAgent_TVEyesResults.ID
										AND	TblMedia.SubMediaType = 'TM'
									INNER JOIN IQAgent_MediaResults with (nolock) 
							ON		IQAgent_MediaResults._MediaID =  IQAgent_TVEyesResults.ID
									AND IQAgent_MediaResults.MediaType='TM'
							WHERE	IQAgent_TVEyesResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
							AND		TblMedia.SRID=TblSearchRequest.ID

							order by MediaDate desc

						) as TMResults
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

			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'PM')
				BEGIN
					Select 
							PMResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
									Top(@NoofRecordDisplay)
									TblMedia.SRID as SearchRequestID,
									IQAgent_MediaResults.ID,
									ISNULL(IQAgent_MediaResults.PositiveSentiment,0) as 'PositiveSentiment' ,
									ISNULL(IQAgent_MediaResults.NegativeSentiment,0) as 'NegativeSentiment',
									IQAgent_MediaResults.Title,
									IQAgent_BLPMResults.BLPMXml as HighlightingText,
									IQAgent_MediaResults.Category,
									IQAgent_MediaResults.MediaDate as 'PubDate',
									IQAgent_BLPMResults.Circulation,
									IQAgent_BLPMResults.FileLocation,
									IQAgent_BLPMResults.Pub_Name
					
							FROM #TblMedia as TblMedia
									INNER JOIN IQAgent_BLPMResults with (nolock) 
										ON TblMedia.ID  = IQAgent_BLPMResults.ID
										AND	TblMedia.SubMediaType = 'PM'
									INNER JOIN IQAgent_MediaResults with (nolock) 
							ON		IQAgent_MediaResults._MediaID =  IQAgent_BLPMResults.ID
										AND IQAgent_MediaResults.MediaType='PM'
							WHERE	IQAgent_BLPMResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
							AND		TblMedia.SRID=TblSearchRequest.ID

							order by MediaDate desc

						)as PMResults
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

			IF EXISTS(SELECT 1 FROM #TblMedia AS ReportConfig WHERE SubMediaType = 'PQ')
				BEGIN
					Select 
							PQResults.*
					From

							#TblSearchRequest as TblSearchRequest
									cross apply 

					(
						SELECT 
									Top(@NoofRecordDisplay)
									TblMedia.SRID as SearchRequestID,
									IQAgent_MediaResults.ID,									
									IQAgent_MediaResults.Title,
									IQAgent_PQResults.HighlightingText,
									IQAgent_MediaResults.Category,
									IQAgent_PQResults.MediaDate,
									IQAgent_PQResults.Authors,
									IQAgent_PQResults.Publication,									
									IQAgent_PQResults.Sentiment.query('/Sentiment/PositiveSentiment').value('.','tinyint') AS PositiveSentiment,
									IQAgent_PQResults.Sentiment.query('/Sentiment/NegativeSentiment').value('.','tinyint') AS NegativeSentiment
					
							FROM #TblMedia as TblMedia									
									INNER JOIN IQAgent_PQResults with (nolock) 
										ON	TblMedia.ID =  IQAgent_PQResults.ID
										AND	TblMedia.SubMediaType = 'PQ'
									INNER JOIN IQAgent_MediaResults with (nolock) 
										ON IQAgent_PQResults.ID  = IQAgent_MediaResults._MediaID
										AND IQAgent_MediaResults.MediaType = 'PQ'				
			
							WHERE	IQAgent_PQResults.IsActive = 1
							AND		IQAgent_MediaResults.IsActive = 1
							AND		TblMedia.SRID=TblSearchRequest.ID

							order by IQAgent_PQResults.MediaDate desc

						)as PQResults
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

			END
		
END