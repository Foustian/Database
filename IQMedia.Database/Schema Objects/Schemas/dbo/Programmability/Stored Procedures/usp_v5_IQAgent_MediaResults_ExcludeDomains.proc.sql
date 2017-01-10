CREATE PROCEDURE [dbo].[usp_v5_IQAgent_MediaResults_ExcludeDomains]
	@ClientGUID uniqueidentifier,
	@ArticleXml xml,
	@SearchRequestXml xml
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY	
		Declare @tempData table(_MediaID bigint,SubMediaType varchar(50))
		Declare @tempRequest table(ID bigint,DomainName varchar(255),SubMediaType varchar(50))

		DECLARE @TempSearchRequest TABLE(ID bigint,SearchTerm xml,SubMediaType varchar(50))
		DECLARE @TempSearchRequestUpdate TABLE(ID bigint)

		DECLARE @NMExcludeXml xml
		DECLARE @LNExcludeXml xml
		DECLARE @SMExcludeXml xml
		DECLARE @BLExcludeXml xml
		DECLARE @FOExcludeXml xml
		DECLARE @TWExcludeXml xml


		INSERT INTO @tempdata		
		Select 
			IQAgent_MediaResults._MediaID,
			IQAgent_MediaResults.v5Category
		From 
			IQAgent_MediaResults WITH (NOLOCK)
				inner join @ArticleXml.nodes('list/item') as Media(X)
					ON Media.X.value('@id', 'bigint') = IQAgent_MediaResults.ID
				INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_MediaResults._SearchRequestID = IQAgent_SearchRequest.ID				
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
		WHERE 
				IQAgent_MediaResults.IsActive = 1 
				AND IQAgent_SearchRequest.IsActive > 0
		UNION ALL
		Select 
			IQAgent_MediaResults_Archive._MediaID,
			IQAgent_MediaResults_Archive.v5Category
		From 
			IQAgent_MediaResults_Archive WITH (NOLOCK)
				inner join @ArticleXml.nodes('list/item') as Media(X)
					ON Media.X.value('@id', 'bigint') = IQAgent_MediaResults_Archive.ID
				INNER JOIN IQAgent_SearchRequest WITH (NOLOCK)
						ON IQAgent_MediaResults_Archive._SearchRequestID = IQAgent_SearchRequest.ID				
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
		WHERE 
				IQAgent_MediaResults_Archive.IsActive = 1 
				AND IQAgent_SearchRequest.IsActive > 0
		
		-- Online News
		SET @NMExcludeXml = (SELECT DISTINCT 
					'"' + CASE WHEN IQAgent_NMResults.ID IS NULL THEN IQAgent_NMResults_Archive.CompeteURL ELSE IQAgent_NMResults.CompeteURL END + '"' as domain
		FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_NMResults WITH (NOLOCK)
						ON	IQAgent_NMResults.id = tmp._MediaID and
						SubMediaType = 'NM'
					LEFT JOIN IQAgent_NMResults_Archive WITH (NOLOCK)
						ON	IQAgent_NMResults_Archive.id = tmp._MediaID and
						SubMediaType = 'NM'
			FOR XML PATH(''))
		
		-- LexisNexis	
		SET @LNExcludeXml = (SELECT DISTINCT 
					'"' + CASE WHEN IQAgent_NMResults.ID IS NULL THEN IQAgent_NMResults_Archive.CompeteURL ELSE IQAgent_NMResults.CompeteURL END + '"' as domain
		FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_NMResults WITH (NOLOCK)
						ON	IQAgent_NMResults.id = tmp._MediaID and
						SubMediaType = 'LN'
					LEFT JOIN IQAgent_NMResults_Archive WITH (NOLOCK)
						ON	IQAgent_NMResults_Archive.id = tmp._MediaID and
						SubMediaType = 'LN'
			FOR XML PATH(''))
	
		-- Social Media
		SET  @SMExcludeXml= (SELECT DISTINCT 
					'"' + CASE WHEN IQAgent_SMResults.ID IS NULL THEN IQAgent_SMResults_Archive.CompeteURL ELSE IQAgent_SMResults.CompeteURL END + '"' as domain
		FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_SMResults WITH (NOLOCK)
						ON	IQAgent_SMResults.id = tmp._MediaID and
						SubMediaType = 'SocialMedia' 
					LEFT JOIN IQAgent_SMResults_Archive WITH (NOLOCK)
						ON	IQAgent_SMResults_Archive.id = tmp._MediaID and
						SubMediaType = 'SocialMedia' 
			FOR XML PATH(''))
	
		-- Blog
		SET  @BLExcludeXml= (SELECT DISTINCT
					'"' + CASE WHEN IQAgent_SMResults.ID IS NULL THEN IQAgent_SMResults_Archive.CompeteURL ELSE IQAgent_SMResults.CompeteURL END + '"' as domain
		FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_SMResults WITH (NOLOCK)
						ON	IQAgent_SMResults.id = tmp._MediaID and
						SubMediaType = 'Blog' 
					LEFT JOIN IQAgent_SMResults_Archive WITH (NOLOCK)
						ON	IQAgent_SMResults_Archive.id = tmp._MediaID and
						SubMediaType = 'Blog' 
			FOR XML PATH(''))
	
		-- Forum
		SET  @FOExcludeXml= (SELECT DISTINCT
					'"' + CASE WHEN IQAgent_SMResults.ID IS NULL THEN IQAgent_SMResults_Archive.CompeteURL ELSE IQAgent_SMResults.CompeteURL END + '"' as domain
		FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_SMResults WITH (NOLOCK)
						ON	IQAgent_SMResults.id = tmp._MediaID and
						SubMediaType = 'Forum' 
					LEFT JOIN IQAgent_SMResults_Archive WITH (NOLOCK)
						ON	IQAgent_SMResults_Archive.id = tmp._MediaID and
						SubMediaType = 'Forum' 
			FOR XML PATH(''))
	
		-- Twitter
		SET @TWExcludeXml = (SELECT DISTINCT 
				'"' + CASE WHEN IQAgent_TwitterResults.ID IS NULL THEN IQAgent_TwitterResults_Archive.actor_preferredname ELSE IQAgent_TwitterResults.actor_preferredname END + '"' as handle
			FROM 
				@tempData tmp	
					LEFT JOIN IQAgent_TwitterResults WITH (NOLOCK)
						ON	IQAgent_TwitterResults.id = tmp._MediaID and
							SubMediaType = 'TW' 
					LEFT JOIN IQAgent_TwitterResults_Archive WITH (NOLOCK)
						ON	IQAgent_TwitterResults_Archive.id = tmp._MediaID and
							SubMediaType = 'TW' 
			FOR XML PATH(''))

		IF (@SearchRequestXml IS NULL)
		BEGIN
			-- Online News
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'NM'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @NMExcludeXml.nodes('domain') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/News/ExlcudeDomains/domain') as MainItems(c)
							Where
								tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- LexisNexis
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'LN'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @LNExcludeXml.nodes('domain') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/LexisNexis/ExlcudeDomains/domain') as MainItems(c)
							Where
								tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Social Media
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'SocialMedia'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @SMExcludeXml.nodes('domain') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner	WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/SocialMedia/ExlcudeDomains/domain') as MainItems(c)
							Where
									tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Blog
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'Blog'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @BLExcludeXml.nodes('domain') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner	WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Blog/ExlcudeDomains/domain') as MainItems(c)
							Where
									tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Forum
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'Forum'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @FOExcludeXml.nodes('domain') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner	WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Forum/ExlcudeDomains/domain') as MainItems(c)
							Where
									tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Twitter
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'TW'
			FROM
			(
				SELECT 
					IQAgent_SearchRequest.ID as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					IQAgent_SearchRequest WITH (NOLOCK)
						CROSS JOIN  @TWExcludeXml.nodes('handle') as NewItems(c)
				Where
					IQAgent_SearchRequest.ClientGUID = @ClientGUID

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
									IQAgent_SearchRequest tblInner WITH (NOLOCK)
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Twitter/ExclusionHandles/handle') as MainItems(c)
							Where
									tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

				-- append new domains to existing list
			-- Online News
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/News/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'NM'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest 	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='NM' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='NM' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/News/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0

			-- LexisNexis
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/LexisNexis/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'LN'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest 	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='LN' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='LN' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/LexisNexis/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Social Media
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/SocialMedia/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'SocialMedia'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='SocialMedia' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='SocialMedia' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/SocialMedia/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Blog
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Blog/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Blog'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='Blog' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='Blog' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Blog/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Forum
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Forum/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Forum'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='Forum' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='Forum' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Forum/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Twitter
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Twitter/ExclusionHandles)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'TW'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<handle>' + DomainName + '</handle>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='TW' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='TW' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Twitter/ExclusionHandles') = 1
				AND IQAgent_SearchRequest.IsActive > 0

			SET @NMExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@NMExcludeXml) + '</ExlcudeDomains>'	
			SET @LNExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@LNExcludeXml) + '</ExlcudeDomains>'		 
			SET @SMExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@SMExcludeXml) + '</ExlcudeDomains>'		 
			SET @BLExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@BLExcludeXml) + '</ExlcudeDomains>'		 
			SET @FOExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@FOExcludeXml) + '</ExlcudeDomains>'		 
			SET @TWExcludeXml = '<ExclusionHandles>' + convert(varchar(max),@TWExcludeXml) + '</ExclusionHandles>'		 
		
			-- insert exclude domain node
			-- Online News
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@NMExcludeXml") as last into (/SearchRequest/News)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'NM'
					INTO @TempSearchRequest
			FROM	
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/News') = 1
					AND SearchTerm.exist('/SearchRequest/News/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			-- LexisNexis
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@LNExcludeXml") as last into (/SearchRequest/LexisNexis)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'LN'
					INTO @TempSearchRequest
			FROM	
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/LexisNexis') = 1
					AND SearchTerm.exist('/SearchRequest/LexisNexis/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			-- Social Media
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@SMExcludeXml") as last into (/SearchRequest/SocialMedia)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'SocialMedia'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/SocialMedia') = 1
					AND SearchTerm.exist('/SearchRequest/SocialMedia/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			-- Blog
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@BLExcludeXml") as last into (/SearchRequest/Blog)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Blog'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/Blog') = 1
					AND SearchTerm.exist('/SearchRequest/Blog/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			-- Forum
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@FOExcludeXml") as last into (/SearchRequest/Forum)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Forum'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/Forum') = 1
					AND SearchTerm.exist('/SearchRequest/Forum/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0
			
			-- Twitter
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@TWExcludeXml") as last into (/SearchRequest/Twitter)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Twitter'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
			WHERE 
					SearchTerm.exist('/SearchRequest/Twitter') = 1
					AND SearchTerm.exist('/SearchRequest/Twitter/ExclusionHandles') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0
		
			-- insert logs if domains not inseted 
			IF(@NMExcludeXml IS NOT NULL AND CONVERT(varchar(max),@NMExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@NMExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as News tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/News') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@LNExcludeXml IS NOT NULL AND CONVERT(varchar(max),@LNExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@LNExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as LexisNexis tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/LexisNexis') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@SMExcludeXml IS NOT NULL AND CONVERT(varchar(max),@SMExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@SMExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Social Media tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/SocialMedia') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@BLExcludeXml IS NOT NULL AND CONVERT(varchar(max),@BLExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@BLExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Blog tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/Blog') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@FOExcludeXml IS NOT NULL AND CONVERT(varchar(max),@FOExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@FOExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Forum tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/Forum') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END
			
			IF(@TWExcludeXml IS NOT NULL AND CONVERT(varchar(max),@TWExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+ replace(CONVERT(Varchar(max),@TWExcludeXml.query('distinct-values( data(/ExclusionHandles/handle) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Twitter tag not exist'
				FROM	
						IQAgent_SearchRequest	 
				WHERE 
						SearchTerm.exist('/SearchRequest/Twitter') = 0	
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END
		END
		ELSE
		BEGIN
			-- Online News
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'NM'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @NMExcludeXml.nodes('domain') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/News/ExlcudeDomains/domain') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- LexisNexis
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'LN'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @LNExcludeXml.nodes('domain') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/LexisNexis/ExlcudeDomains/domain') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Social Media
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'SocialMedia'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @SMExcludeXml.nodes('domain') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/SocialMedia/ExlcudeDomains/domain') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Blog
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'Blog'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @BLExcludeXml.nodes('domain') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Blog/ExlcudeDomains/domain') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Social Media
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'Forum'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @FOExcludeXml.nodes('domain') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Forum/ExlcudeDomains/domain') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

			-- Twitter
			INSERT INTO @tempRequest
			SELECT 
				tblDistinct.ID,
				tblDistinct.item,
				'TW'
			FROM
			(
				SELECT 
					Request.X.value('@id','bigint') as ID,
					NewItems.c.query('.').value('.','varchar(max)') as item
				FROM
					@SearchRequestXml.nodes('list/item') as Request(X)
						CROSS JOIN  @TWExcludeXml.nodes('handle') as NewItems(c)

				EXCEPT

				SELECT
					tblMain.ID,
					item
				FROM
					IQAgent_SearchRequest as tblMain WITH (NOLOCK)
						INNER JOIN
						(
							SELECT 
								tblInner.ID,
								MainItems.c.query('.').value('.','varchar(max)') as item   
							FROM 
								@SearchRequestXml.nodes('list/item') as Request(X) 
									INNER JOIN IQAgent_SearchRequest tblInner WITH (NOLOCK)
										ON tblInner.ID = Request.X.value('@id','bigint')
									cross apply
											tblInner.SearchTerm.nodes('/SearchRequest/Twitter/ExclusionHandles/handle') as MainItems(c)
							WHERE
								 tblInner.ClientGUID = @ClientGUID
						) as tblSub 
							ON tblMain.ID = tblSub.ID
			) as tblDistinct

				-- append new domains to existing list
			-- Online News
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/News/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'NM'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='NM' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='NM' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/News/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0

			-- LexisNexis
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/LexisNexis/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'LN'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='LN' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='LN' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/LexisNexis/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Social Media
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/SocialMedia/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'SocialMedia'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='SocialMedia' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='SocialMedia' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/SocialMedia/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Blog
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Blog/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Blog'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='Blog' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='Blog' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Blog/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Forum
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Forum/ExlcudeDomains)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Forum'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<domain>' + DomainName + '</domain>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='Forum' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='Forum' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Forum/ExlcudeDomains') = 1
				AND IQAgent_SearchRequest.IsActive > 0
			
			-- Twitter
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:column("values") as last into (/SearchRequest/Twitter/ExclusionHandles)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'TW'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN 
						(
							select t.id, convert(xml,STUFF(( 
								select '<handle>' + DomainName + '</handle>' 
								from @tempRequest tbl2 
								where tbl2.id=t.id and tbl2.SubMediaType ='TW' 
								for xml path(''), type).value('.', 'varchar(max)'), 1, 0, '')) [values] 
							from @tempRequest t
							where t.SubMediaType ='TW' 
							group by t.id
						) as tmp	
				
					ON IQAgent_SearchRequest.ID  = tmp.ID
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
							AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			WHERE 
					SearchTerm.exist('/SearchRequest/Twitter/ExclusionHandles') = 1
				AND IQAgent_SearchRequest.IsActive > 0

			SET @NMExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@NMExcludeXml) + '</ExlcudeDomains>'		
			SET @LNExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@LNExcludeXml) + '</ExlcudeDomains>'	 
			SET @SMExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@SMExcludeXml) + '</ExlcudeDomains>'	
			SET @BLExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@BLExcludeXml) + '</ExlcudeDomains>'	
			SET @FOExcludeXml = '<ExlcudeDomains>' + convert(varchar(max),@FOExcludeXml) + '</ExlcudeDomains>'		 
			SET @TWExcludeXml = '<ExclusionHandles>' + convert(varchar(max),@TWExcludeXml) + '</ExclusionHandles>'		 
		
			-- insert exclude domain node
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@NMExcludeXml") as last into (/SearchRequest/News)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'NM'
					INTO @TempSearchRequest
			FROM	
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			WHERE 
					SearchTerm.exist('/SearchRequest/News') = 1
					AND SearchTerm.exist('/SearchRequest/News/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0
					
			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@LNExcludeXml") as last into (/SearchRequest/LexisNexis)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'LN'
					INTO @TempSearchRequest
			FROM	
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			WHERE 
					SearchTerm.exist('/SearchRequest/LexisNexis') = 1
					AND SearchTerm.exist('/SearchRequest/LexisNexis/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@SMExcludeXml") as last into (/SearchRequest/SocialMedia)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'SocialMedia'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			
			WHERE 
					SearchTerm.exist('/SearchRequest/SocialMedia') = 1
					AND SearchTerm.exist('/SearchRequest/SocialMedia/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@BLExcludeXml") as last into (/SearchRequest/Blog)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Blog'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			
			WHERE 
					SearchTerm.exist('/SearchRequest/Blog') = 1
					AND SearchTerm.exist('/SearchRequest/Blog/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@FOExcludeXml") as last into (/SearchRequest/Forum)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'Forum'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			
			WHERE 
					SearchTerm.exist('/SearchRequest/Forum') = 1
					AND SearchTerm.exist('/SearchRequest/Forum/ExlcudeDomains') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0

			UPDATE 	IQAgent_SearchRequest	
			SET 
					SearchTerm.modify('insert sql:variable("@TWExcludeXml") as last into (/SearchRequest/Twitter)[1]')
					OUTPUT deleted.ID,deleted.SearchTerm,'TW'
					INTO @TempSearchRequest
			FROM 
					IQAgent_SearchRequest	 
						INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
							ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
			WHERE 
					SearchTerm.exist('/SearchRequest/Twitter') = 1
					AND SearchTerm.exist('/SearchRequest/Twitter/ExclusionHandles') = 0
					AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
					AND IQAgent_SearchRequest.IsActive > 0


-- insert logs if domains not inseted 
			IF(@NMExcludeXml IS NOT NULL AND CONVERT(varchar(max),@NMExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@NMExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as News tag not exist'
				FROM	
						IQAgent_SearchRequest	 
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
				WHERE 
						SearchTerm.exist('/SearchRequest/News') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@LNExcludeXml IS NOT NULL AND CONVERT(varchar(max),@LNExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@LNExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as LexisNexis tag not exist'
				FROM	
						IQAgent_SearchRequest	 
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
				WHERE 
						SearchTerm.exist('/SearchRequest/LexisNexis') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@SMExcludeXml IS NOT NULL AND CONVERT(varchar(max),@SMExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@SMExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Social Media tag not exist'
				FROM	
						IQAgent_SearchRequest	 
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
				WHERE 
						SearchTerm.exist('/SearchRequest/SocialMedia') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@BLExcludeXml IS NOT NULL AND CONVERT(varchar(max),@BLExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@BLExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Blog tag not exist'
				FROM	
						IQAgent_SearchRequest	
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint') 
				WHERE 
						SearchTerm.exist('/SearchRequest/Blog') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END

			IF(@FOExcludeXml IS NOT NULL AND CONVERT(varchar(max),@FOExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+replace(CONVERT(Varchar(max),@FOExcludeXml.query('distinct-values( data(/ExlcudeDomains/domain) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Forum tag not exist'
				FROM	
						IQAgent_SearchRequest	 
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
				WHERE 
						SearchTerm.exist('/SearchRequest/Forum') = 0
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END
			
			IF(@TWExcludeXml IS NOT NULL AND CONVERT(varchar(max),@TWExcludeXml) != '')
			BEGIN
				INSERT INTO 
					IQAgent_ExcludeSkippedLog
					(
						SP,
						ClientGuid,
						[Message]
					)
				SELECT
						DISTINCT 
						'usp_v5_IQAgent_MediaResults_ExcludeDomains',
						IQAgent_SearchRequest.ClientGUID,
						'tried to exclude domains '+ replace(CONVERT(Varchar(max),@TWExcludeXml.query('distinct-values( data(/ExclusionHandles/handle) )')),' ',',')+' for search request : ' + CONVERT(varchar(10),IQAgent_SearchRequest.ID) +' but failed as Twitter tag not exist'
				FROM	
						IQAgent_SearchRequest	 
							INNER JOIN @SearchRequestXml.nodes('list/item') as Request(X) 
								ON IQAgent_SearchRequest.ID = Request.X.value('@id','bigint')
				WHERE 
						SearchTerm.exist('/SearchRequest/Twitter') = 0	
						AND IQAgent_SearchRequest.ClientGUID = @ClientGUID
			END
		END

		-- Online News
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							news.x.value('.','varchar(max)')as newsitem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/News/ExlcudeDomains/domain') as news(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/News/ExlcudeDomains/domain') as news(y)
								on tmpRequest.ID = t3.id
								AND t3.SubMediaType ='NM'
								and  newsitem = news.y.value('.','varchar(max)')
						
		where 
						(
						news.y.value('.','varchar(max)') is null 
						)

		-- LexisNexis
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							news.x.value('.','varchar(max)')as newsitem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/LexisNexis/ExlcudeDomains/domain') as news(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/LexisNexis/ExlcudeDomains/domain') as news(y)
								on tmpRequest.ID = t3.id
								AND t3.SubMediaType ='LN'
								and  newsitem = news.y.value('.','varchar(max)')
						
		where 
						(
						news.y.value('.','varchar(max)') is null 
						)

		-- Social Media
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							social.x.value('.','varchar(max)')as socialitem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/SocialMedia/ExlcudeDomains/domain') as social(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/SocialMedia/ExlcudeDomains/domain') as social(y)
								on tmpRequest.ID = t3.id
								and  socialitem = social.y.value('.','varchar(max)')
								and t3.SubMediaType ='SocialMedia' 
						
		where 
						
						(
						social.y.value('.','varchar(max)') is null 
						)

		-- Blog
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							social.x.value('.','varchar(max)')as socialitem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/Blog/ExlcudeDomains/domain') as social(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/Blog/ExlcudeDomains/domain') as social(y)
								on tmpRequest.ID = t3.id
								and  socialitem = social.y.value('.','varchar(max)')
								and t3.SubMediaType ='Blog' 
						
		where 
						
						(
						social.y.value('.','varchar(max)') is null 
						)

		-- Forum
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							social.x.value('.','varchar(max)')as socialitem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/Forum/ExlcudeDomains/domain') as social(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/Forum/ExlcudeDomains/domain') as social(y)
								on tmpRequest.ID = t3.id
								and  socialitem = social.y.value('.','varchar(max)')
								and t3.SubMediaType ='Forum' 
						
		where 
						
						(
						social.y.value('.','varchar(max)') is null 
						)

		-- Twitter
		INSERT INTO @TempSearchRequestUpdate
		select distinct 
			tmpRequest.id
			from
					(
						select distinct
							t1.id,
							Twitter.x.value('.','varchar(max)')as Twitteritem
						from
							IQAgent_SearchRequest t1 WITH (NOLOCK)
									cross apply t1.SearchTerm.nodes('SearchRequest/Twitter/ExclusionHandles/handle') as Twitter(x)
															inner join @TempSearchRequest t2 
									ON t1.ID = t2.id 
					) as tmpRequest 

							left outer join @TempSearchRequest t3 
									cross apply t3.SearchTerm.nodes('SearchRequest/Twitter/ExclusionHandles/handle') as Twitter(y)
								on tmpRequest.ID = t3.id
								and  Twitteritem = Twitter.y.value('.','varchar(max)')
								AND t3.SubMediaType ='TW' 
		where 
						(
						Twitter.y.value('.','varchar(max)') is null 
						)
				

		update IQAgent_SearchRequest
		set 
			v4SearchTerm = SearchTerm,
			Query_Version = Query_Version + 1,
			ModifiedDate = GETDATE()
		FROM 
			IQAgent_SearchRequest inner join @TempSearchRequestUpdate as temp on IQAgent_SearchRequest.ID = temp.ID and IQAgent_SearchRequest.IsActive > 0

		INSERT INTO IQAgent_SearchRequest_History
					(
						_SearchRequestID,
						[Version],
						SearchRequest,
						Name,
						DateCreated,
						v4SearchRequest
					)
			SELECT
					IQAgent_SearchRequest.ID,
					max(IQAgent_SearchRequest.Query_Version),
					max(convert(varchar(max),IQAgent_SearchRequest.SearchTerm)),
					max(IQAgent_SearchRequest.Query_Name),
					GETDATE(),
					max(convert(varchar(max),IQAgent_SearchRequest.v4SearchTerm))
			FROM 
					IQAgent_SearchRequest WITH (NOLOCK) inner join @TempSearchRequestUpdate as temp on IQAgent_SearchRequest.ID = temp.ID and IQAgent_SearchRequest.IsActive > 0
			group by IQAgent_SearchRequest.ID
					

		Select 1

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	
		ROLLBACK TRANSACTION
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v5_IQAgent_MediaResults_ExcludeDomains',
				@ModifiedBy='usp_v5_IQAgent_MediaResults_ExcludeDomains',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		
		exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH
END