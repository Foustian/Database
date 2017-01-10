CREATE PROCEDURE [dbo].[usp_isvc_IQAgent_SearchRequest_DeleteRequest]
	@SearchRequestKey	BIGINT,
	@CustomerGuid UNIQUEIDENTIFIER ,
	@ClientGuid UNIQUEIDENTIFIER 
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;
	
	IF NOT EXISTS (SELECT 1 FROM IQAgent_DeleteControl WHERE searchRequestID = @SearchRequestKey)
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
							
				DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionStackTrace VARCHAR(500),
				@ExceptionMessage VARCHAR(500),
				@CreatedBy	VARCHAR(50),
				@ModifiedBy	VARCHAR(50),
				@CreatedDate	DATETIME,
				@ModifiedDate	DATETIME,
				@IsActive	BIT
							
					
				SELECT 
					@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
					@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
					@CreatedBy='usp_isvc_IQAgent_SearchRequest_DeleteRequest',
					@ModifiedBy='usp_isvc_IQAgent_SearchRequest_DeleteRequest',
					@CreatedDate=GETDATE(),
					@ModifiedDate=GETDATE(),
					@IsActive=1
					
			
				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
			END CATCH
		END
	ELSE
		BEGIN
			SELECT -2
		END
END
