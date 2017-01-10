CREATE PROCEDURE [dbo].[usp_v4_IQAgent_SearchRequest_DeleteRequest]
	@SearchRequestKey bigint,
	@CustomerGuid uniqueidentifier,
	@ClientGuid uniqueidentifier 
AS
BEGIN

	SET XACT_ABORT ON;

	IF NOT EXISTS (SELECT 1 FROM IQAgent_DeleteControl WHERE searchRequestID = @SearchRequestKey AND isSolrUpdated != 'COMPLETED')
		BEGIN
			BEGIN TRANSACTION;        
			BEGIN TRY

				UPDATE 
						IQAgent_SearchRequest 
				SET 
						IsActive = 0,
						ModifiedDate = GETDATE()
				WHERE 
						ID = @SearchRequestKey
						AND ClientGUID = @ClientGuid

				DECLARE @RowCount INT=@@ROWCOUNT

				IF(@RowCount=1)
				BEGIN

					INSERT INTO IQAgent_DeleteControl
				(
						clientGUID,
						customerGUID,
						createdDate,
						modifiedDate,
						isDBUpdated,
						isSolrUpdated,
						searchRequestID
				)
				VALUES
				(
						@ClientGuid,
						@CustomerGuid,
						getdate(),
						getdate(),
						'TEMP',
						'TEMP',
						@SearchRequestKey
				)

					CREATE TABLE #TempDelete (NotificationKey bigint, TotalCount int)

					INSERT INTO #TempDelete
					SELECT 
						IQNotificationSettings.IQNotificationKey,
						IQNotificationSettings.SearchRequestList.value('count(SearchRequestIDList/SearchRequestID)', 'int') TotalNodes
					FROM 
						IQNotificationSettings
							cross apply IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as search(ids)
					WHERE
						search.ids.value('.','bigint') = @SearchRequestKey
						and IQNotificationSettings.ClientGuid = @ClientGuid


					update
							IQNotificationSettings
					SET
							IsActive = 0
					FROM 
							IQNotificationSettings
								inner join #TempDelete tmp
									on IQNotificationSettings.IQNotificationKey = tmp.NotificationKey
									and tmp.TotalCount = 1
					WHERE IQNotificationSettings.ClientGuid = @ClientGuid
				
					update
							IQNotificationSettings
					SET
							SearchRequestList.modify('delete /SearchRequestIDList/SearchRequestID[. = sql:variable("@SearchRequestKey")]')
					
					FROM 
							IQNotificationSettings
								inner join #TempDelete tmp
									on IQNotificationSettings.IQNotificationKey = tmp.NotificationKey
									and tmp.TotalCount > 1
					WHERE IQNotificationSettings.ClientGuid = @ClientGuid

					-- If Twitter is active, deactivate the appropriate record in IQ_Twitter_Settings
					DECLARE @GnipTag VARCHAR(MAX)
					SELECT	
						@GnipTag = SearchTerm.query('SearchRequest/Twitter/GnipTagList/GnipTag').value('.', 'varchar(max)')
					FROM	
						IQAgent_SearchRequest WITH (NOLOCK)
					WHERE	
						ID = @SearchRequestKey
						AND ClientGUID = @ClientGuid
	
					IF ISNULL(@GnipTag, '') != ''
					  BEGIN
						UPDATE IQ_Twitter_Settings
						SET IsActive = 0,
							ModifiedDate = GETDATE()
						WHERE UserTrackGUID = @GnipTag

						exec usp_v5_IQService_TwitterSettings_Insert @ClientGuid, @CustomerGuid, @SearchRequestKey, 0
					  END

					-- If TVEyes Radio is active, deactivate the appropriate record in IQ_TVEyes_Settings
					DECLARE @TVESettingsKey VARCHAR(MAX)
					SELECT	
						@TVESettingsKey = SearchTerm.query('SearchRequest/TM/TVEyesSettingsKey').value('.', 'bigint')
					FROM	
						IQAgent_SearchRequest WITH (NOLOCK)
					WHERE	
						ID = @SearchRequestKey
						AND ClientGUID = @ClientGuid
	
					IF @TVESettingsKey != 0
					  BEGIN
						UPDATE IQ_TVEyes_Settings
						SET IsActive = 0,
							ModifiedDate = GETDATE()
						WHERE TVESettingsKey = @TVESettingsKey

						exec usp_v5_IQService_TVEyesSettings_Insert @ClientGuid, @CustomerGuid, @SearchRequestKey, 0
					  END
				END

				SELECT @RowCount

				COMMIT TRANSACTION;  
			END TRY
				BEGIN CATCH          
				ROLLBACK TRANSACTION;    

				SELECT -1
							
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
					@CreatedBy='usp_v4_IQAgent_SearchRequest_DeleteRequest',
					@ModifiedBy='usp_v4_IQAgent_SearchRequest_DeleteRequest',
					@CreatedDate=GETDATE(),
					@ModifiedDate=GETDATE(),
					@IsActive=1
					
			
				exec usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output    
			END CATCH
		END
	ELSE
		BEGIN
			SELECT -2
		END
END
