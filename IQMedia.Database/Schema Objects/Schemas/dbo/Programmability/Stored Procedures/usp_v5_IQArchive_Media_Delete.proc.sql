CREATE PROCEDURE [dbo].[usp_v5_IQArchive_Media_Delete]
	@ClientGUID		UNIQUEIDENTIFIER,
	@ArchiveXML		XML,
	@v4LibraryRollup bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Result AS TABLE (ArchiveID BIGINT)

	IF @ArchiveXML Is NOT NULL
		BEGIN
			
			DECLARE @tblArchiveID AS TABLE(ID INT IDENTITY(1,1),ArchiveID BIGINT)
			
			DECLARE @MultiPlier float
			select @MultiPlier = CONVERT(float,ISNULL((select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = @ClientGUID),(select Value from IQClient_CustomSettings where Field = 'Multiplier' and _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))))

			INSERT INTO @tblArchiveID ( ArchiveID )
			SELECT	tbl.c.query('.').value('.','BIGINT')
			FROM	@ArchiveXML.nodes('list/id') as tbl(c)
		
			DECLARE @Count AS INT
			SET @Count = 0
			
			WHILE @Count <= (SELECT COUNT(*) FROM @tblArchiveID)
				BEGIN
						DECLARE @ID AS BIGINT
						DECLARE @ArchiveMediaID AS BIGINT,@DataModelType AS VARCHAR(10),@UpdateRowCount AS INT
						
						SET @ArchiveMediaID = NULL
						SET @DataModelType = NULL
						SET @UpdateRowCount = NULL
			
						SET @UpdateRowCount = 0
						SET @ID = (SELECT ArchiveID FROM @tblArchiveID WHERE ID = @Count)
						
						SELECT 
								@ArchiveMediaID = _ArchiveMediaID,
								@DataModelType = DataModelType
						FROM	IQArchive_Media WITH (NOLOCK)
						INNER	JOIN IQ_MediaTypes 
								ON IQ_MediaTypes.SubMediaType = IQArchive_Media.SubMediaType
								AND IQ_MediaTypes.TypeLevel = 2
						WHERE	IQArchive_Media.ID = @ID
			
						BEGIN TRANSACTION
			
						IF @ArchiveMediaID > 0 AND (@DataModelType IS NOT NULL AND LEN(@DataModelType) > 0)
							BEGIN
					
								-- Remove record from IQArchive_Media table(Just Update IsActive column)
								
								UPDATE IQArchive_Media 
								SET IsActive = 0
								FROM IQArchive_Media 
								INNER JOIN Client
								ON		IQArchive_Media.ClientGUID = Client.ClientGUID
								AND		IQArchive_Media.ID = @ID
								AND		IQArchive_Media.ClientGUID = @ClientGUID
								AND		IQArchive_Media.IsActive = 1
								WHERE	IQArchive_Media.ID = @ID
					
								SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT

								if(@v4LibraryRollup =1 )
								begin
									UPDATE IQArchive_Media 
									SET IsActive = 0
									FROM IQArchive_Media 
									INNER JOIN Client
									ON		IQArchive_Media.ClientGUID = Client.ClientGUID
									AND		IQArchive_Media._ParentID = @ID
									AND		IQArchive_Media.ClientGUID = @ClientGUID
									AND		IQArchive_Media.IsActive = 1
									WHERE	IQArchive_Media._ParentID = @ID
								end
					
								IF @DataModelType = 'PM'
									BEGIN
								
										-- Remove record from ArchiveBLPM table(Just Update IsActive column)
										
										UPDATE ArchiveBLPM 
										SET IsActive = 0,
										ModifiedDate = GETDATE()
										FROM ArchiveBLPM 
										INNER JOIN Client
										ON		ArchiveBLPM.ClientGUID = Client.ClientGUID
										AND		ArchiveBLPM.ArchiveBLPMKey = @ArchiveMediaID
										AND		ArchiveBLPM.ClientGUID = @ClientGUID
										AND		ArchiveBLPM.IsActive = 1
										WHERE	ArchiveBLPM.ArchiveBLPMKey = @ArchiveMediaID
										
										SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
										
									END
						
								IF @DataModelType = 'NM'
									BEGIN
								
										-- Remove record from ArchiveNM table(Just Update IsActive column)
										
										UPDATE ArchiveNM 
										SET IsActive = 0,
										ModifiedDate = GETDATE()
										FROM ArchiveNM 
										INNER JOIN Client
										ON		ArchiveNM.ClientGUID = Client.ClientGUID
										AND		ArchiveNM.ArchiveNMKey = @ArchiveMediaID
										AND		ArchiveNM.ClientGUID = @ClientGUID
										AND		ArchiveNM.IsActive = 1
										WHERE	ArchiveNM.ArchiveNMKey = @ArchiveMediaID
										
										SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT

										if(@v4LibraryRollup =1 )
											begin
												UPDATE ArchiveNM 
												SET IsActive = 0,
												ModifiedDate = GETDATE()
												output deleted.ArchiveNMKey into @Result
												FROM ArchiveNM 
													INNER JOIN IQArchive_Media
														ON ArchiveNM.ArchiveNMKey = IQArchive_Media._ArchiveMediaID
														AND IQArchive_Media.v5SubMediaType=ArchiveNM.v5SubMediaType
													INNER JOIN Client
														ON		ArchiveNM.ClientGUID = Client.ClientGUID
														AND		IQArchive_Media.ClientGUID = Client.ClientGUID
														AND		ArchiveNM.ClientGUID = @ClientGUID
														AND		ArchiveNM.IsActive = 1
												WHERE	
														IQArchive_Media._ParentID = @ID
											end
									END
						
									IF @DataModelType = 'TV'
										BEGIN
									
											-- Remove record from ArchiveClip table(Just Update IsActive column)
											
											UPDATE ArchiveClip 
											SET IsActive = 0,
											ModifiedDate = GETDATE()
											FROM ArchiveClip 
											INNER JOIN Client
											ON		ArchiveClip.ClientGUID = Client.ClientGUID
											AND		ArchiveClip.ArchiveClipKey = @ArchiveMediaID
											AND		ArchiveClip.ClientGUID = @ClientGUID
											AND		ArchiveClip.IsActive = 1
											WHERE	ArchiveClip.ArchiveClipKey = @ArchiveMediaID
											
											SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT

											if(@v4LibraryRollup =1 )
											begin
												UPDATE ArchiveClip 
												SET IsActive = 0,
												ModifiedDate = GETDATE()
												output deleted.ArchiveClipKey into @Result
												FROM ArchiveClip 
													INNER JOIN IQArchive_Media
														ON ArchiveClip.ArchiveClipKey = IQArchive_Media._ArchiveMediaID
														AND IQArchive_Media.v5SubMediaType=ArchiveClip.v5SubMediaType
													INNER JOIN Client
														ON		ArchiveClip.ClientGUID = Client.ClientGUID
														AND		IQArchive_Media.ClientGUID = Client.ClientGUID
														AND		ArchiveClip.ClientGUID = @ClientGUID
														AND		ArchiveClip.IsActive = 1
												WHERE	
														IQArchive_Media._ParentID = @ID
											end
										END
						
										IF @DataModelType = 'TW'
											BEGIN
										
												-- Remove record from ArchiveTweets table(Just Update IsActive column)
												
												UPDATE ArchiveTweets 
												SET IsActive = 0,
												ModifiedDate = GETDATE()
												FROM ArchiveTweets 
												INNER JOIN Client
												ON		ArchiveTweets.ClientGUID = Client.ClientGUID
												AND		ArchiveTweets.ArchiveTweets_Key = @ArchiveMediaID
												AND		ArchiveTweets.ClientGUID = @ClientGUID
												AND		ArchiveTweets.IsActive = 1
												WHERE	ArchiveTweets.ArchiveTweets_Key = @ArchiveMediaID
												
												SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
											END
						
											IF @DataModelType = 'SM'
												BEGIN
											
													-- Remove record from ArchiveSM table(Just Update IsActive column)
													
													UPDATE ArchiveSM 
													SET IsActive = 0,
													ModifiedDate = GETDATE()
													FROM ArchiveSM 
													INNER JOIN Client
													ON		ArchiveSM.ClientGUID = Client.ClientGUID
													AND		ArchiveSM.ArchiveSMKey = @ArchiveMediaID
													AND		ArchiveSM.ClientGUID = @ClientGUID
													AND		ArchiveSM.IsActive = 1
													WHERE	ArchiveSM.ArchiveSMKey = @ArchiveMediaID
													
													SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
												END

										IF @DataModelType = 'TM'
												BEGIN
											
													-- Remove record from ArchiveSM table(Just Update IsActive column)
													
													UPDATE ArchiveTVEyes 
													SET IsActive = 0,
													ModifiedDate = GETDATE()
													FROM ArchiveTVEyes 
													INNER JOIN Client
													ON		ArchiveTVEyes.ClientGUID = Client.ClientGUID
													AND		ArchiveTVEyes.ArchiveTVEyesKey = @ArchiveMediaID
													AND		ArchiveTVEyes.ClientGUID = @ClientGUID
													AND		ArchiveTVEyes.IsActive = 1
													WHERE	ArchiveTVEyes.ArchiveTVEyesKey = @ArchiveMediaID
													
													SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
												END
					
										IF @DataModelType = 'MS'
											BEGIN
								
												-- Remove record from ArchiveMisc table(Just Update IsActive column)
										
												UPDATE ArchiveMisc 
												SET IsActive = 0,
												ModifiedDate = GETDATE()
												FROM ArchiveMisc 
												INNER JOIN Client
												ON		ArchiveMisc.ClientGUID = Client.ClientGUID
												AND		ArchiveMisc.ArchiveMiscKey = @ArchiveMediaID
												AND		ArchiveMisc.ClientGUID = @ClientGUID
												AND		ArchiveMisc.IsActive = 1
												WHERE	ArchiveMisc.ArchiveMiscKey = @ArchiveMediaID
										
												SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
										
											END

										IF @DataModelType = 'PQ'
												BEGIN
											
													-- Remove record from ArchivePQ table(Just Update IsActive column)
													
													UPDATE ArchivePQ 
													SET IsActive = 0,
													ModifiedDate = GETDATE()
													FROM ArchivePQ 
													INNER JOIN Client
													ON		ArchivePQ.ClientGUID = Client.ClientGUID
													AND		ArchivePQ.ArchivePQKey = @ArchiveMediaID
													AND		ArchivePQ.ClientGUID = @ClientGUID
													AND		ArchivePQ.IsActive = 1
													WHERE	ArchivePQ.ArchivePQKey = @ArchiveMediaID
													
													SET @UpdateRowCount = @UpdateRowCount + @@ROWCOUNT
												END
						
								END								
								
								IF @UpdateRowCount = 2
									BEGIN
										INSERT INTO @Result(ArchiveID) VALUES (@ID)

										COMMIT TRANSACTION
									END
								ELSE
									BEGIN
										ROLLBACK TRANSACTION
									END
						SET @Count = @Count + 1
				END
		END
		
		
		SELECT * FROM @Result	

		IF(@v4LibraryRollup = 1) begin
			SELECT 
			IQArchive_Media.ID,
				_ArchiveMediaID,
				IQArchive_Media.Title,
				IQArchive_Media.HighlightingText,
				IQArchive_Media.Content,
				IQArchive_Media.MediaDate,
				IQArchive_Media.v5MediaType as MediaType,
				IQArchive_Media.v5SubMediaType as SubMediaType,
				IQArchive_Media.CreatedDate,
				ArchiveClip.ClipID,
				ArchiveClip.ClipDate,
				Nielsen_Audience,
				IQAdShareValue,
				Nielsen_Result,
				(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
				(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
				(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
				(Select  Dma_Num From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Dma_Num',
				ArchiveClip.PositiveSentiment,
				ArchiveClip.NegativeSentiment,
				ArchiveClip.Description,
				IQArchive_Media.DisplayDescription,
				(SELECT Top 1 IQSSP_NationalNielsen.Audience FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_Nielsen_Audience,
				(SELECT Top 1  (IQSSP_NationalNielsen.MediaValue * @MultiPlier *  (CONVERT(decimal(18,2),(IQCore_Clip.endOffset - IQCore_Clip.startOffset + 1)) /30 )) FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_IQAdShareValue,
				(SELECT Top 1 CASE WHEN IQSSP_NationalNielsen.IsActual = 0 THEN 'E' ELSE 'A' END FROM IQSSP_NationalNielsen Where LocalDate = CONVERT(Date,ArchiveClip.ClipDate) AND Title120 = ArchiveClip.Title120 and Station_Affil = (Select Station_Affil From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key)))) as National_Nielsen_Result
			FROM	@Result AS TempResults
			INNER JOIN IQArchive_Media on
				IQArchive_Media.ID = ( SELECT _ParentID FROM IQArchive_Media Where ID = TempResults.ArchiveID)
				AND IQArchive_Media.IsActive = 1
			INNER JOIN ArchiveClip
			ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey
			AND	IQArchive_Media.v5SubMediaType=ArchiveClip.v5SubMediaType
			AND ArchiveClip.IsActive = 1
			INNER JOIN IQCore_Clip 
			ON ArchiveClip.ClipID = IQCore_Clip.[Guid]

			SELECT 
				IQArchive_Media._ParentID,
				IQArchive_Media.ID,
				_ArchiveMediaID,
				IQArchive_Media.Title,
				IQArchive_Media.HighlightingText,
				IQArchive_Media.Content,
				IQArchive_Media.MediaDate,
				IQArchive_Media.v5MediaType as MediaType,
				IQArchive_Media.v5SubMediaType as SubMediaType,
				IQArchive_Media.CreatedDate,
				ArchiveClip.ClipID,
				ArchiveClip.ClipDate,
				Nielsen_Audience,
				IQAdShareValue,
				Nielsen_Result,
				(Select Dma_Name From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Market',
				(Select IQ_Station_ID From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'StationLogo',
				(Select TimeZone From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'TimeZone',
				(Select  Dma_Num From IQ_Station Where IQ_Station_ID = SUBSTRING(IQ_CC_Key,0 ,CHARINDEX('_',IQ_CC_Key))) as 'Dma_Num',
				ArchiveClip.PositiveSentiment,
				ArchiveClip.NegativeSentiment
			FROM	@Result AS TempResults
			INNER JOIN IQArchive_Media on
				IQArchive_Media._ParentID = ( SELECT _ParentID FROM IQArchive_Media Where ID = TempResults.ArchiveID)
				AND IQArchive_Media.IsActive = 1
			INNER JOIN ArchiveClip
			ON IQArchive_Media._ArchiveMediaID = ArchiveClip.ArchiveClipKey
			AND	IQArchive_Media.v5SubMediaType=ArchiveClip.v5SubMediaType
			AND ArchiveClip.IsActive = 1
		end


END
