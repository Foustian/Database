-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_Update]
	@CustomerGuid	uniqueidentifier,
	@IQPremiumSearchRequest	xml,
	@Title varchar(150),
	@Description varchar(500),
	@CategoryGuid uniqueidentifier,
	@IsDefualtSearch bit,
	@IsIQAgent bit,
	@ClientGUID		uniqueidentifier,
	@ID bigint,
	@IsSearchTermEqual bit,
	@OutputStatus int output,
	@OutputTitle varchar(150) output,
	@IQAgentStatus int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		IF NOT EXISTS(SELECT Title From IQCustomer_SavedSearch Where CustomerGuid = @CustomerGuid AND Title = @Title AND ID != @ID AND IsActive = 1)
		BEGIN
		
				DECLARE @IsIQagentInsertAllowed bit

				IF(@ISIQAgent =1)
					BEGIN

							IF((SELECT ISIQAgent FROM IQCustomer_SavedSearch WHERE ID = @ID AND ISACTIVE = 1) = 0)
							
								BEGIN									
										IF(
												(Select Count(*) from IQAgent_SearchRequest where clientGUID = @ClientGUID And IsActive = 1)					
												>=
												ISNULL((Select Value from IQClient_CustomSettings Where _clientGuid = @ClientGUID And Field = 'TotalNoOfIQAgent'),(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field ='TotalNoOfIQAgent'))
											)
							
										BEGIN
											Set @IsIQagentInsertAllowed = 0
										END
									ELSE
										BEGIN
											Set @IsIQagentInsertAllowed = 1
										END					
								END
							ELSE 
								BEGIN							
											Set @IsIQagentInsertAllowed = 1
								END
								
						END
					ELSE
						BEGIN
								Set @IsIQagentInsertAllowed = 0
						END

				
					
					
			SELECT @OutputTitle = Title From IQCustomer_SavedSearch Where CustomerGuid = @CustomerGuid AND convert(nvarchar(max),IQPremiumSearchRequest) = convert(nvarchar(max),@IQPremiumSearchRequest) AND IsActive = 1 AND ID != @ID
			print @OutputTitle
			IF(ISNULL(@OutputTitle,'') = '')
			BEGIN
				print 'into update IQCustomer_SavedSearch'
				Update
						IQCustomer_SavedSearch
				Set 
						CustomerGuid = @CustomerGuid,
						IQPremiumSearchRequest = @IQPremiumSearchRequest,
						Title = @Title,
						[Description] = @Description,
						CategoryGuid = @CategoryGuid,
						IsIQAgent = @IsIQagentInsertAllowed
									
				Where	
						ID = @ID
				------------------
				IF(@IsDefualtSearch = 1)
				BEGIN
					IF Exists(Select Value From IQCustomer_DefaultSettings Where Field = 'IQPremium' AND _CustomerGuid = @CustomerGuid)
					BEGIN
							UPDATE
									IQCustomer_DefaultSettings
							SET															
									Value = @ID
							Where
									Field = 'IQPremium' AND _CustomerGuid = @CustomerGuid															
											
					END -- EXISTS CONDITION'S IF PART ENDS
					ELSE
					BEGIN
							INSERT INTO IQCustomer_DefaultSettings	
								(Field,Value,_CustomerGuid)	
									Select  TOP 1
											'IQPremium',
											@ID,
											@CustomerGuid
									FROM 
											IQCustomer_SavedSearch IQCS
												LEFT OUTER JOIN IQCustomer_DefaultSettings IQCD
													ON IQCD.Field = 'IQPremium' 
													AND IQCS.CustomerGuid = IQCD._CustomerGuid
													AND IQCS.CustomerGuid =@CustomerGuid
									where IQCD._CustomerGuid IS NULL
																	
							UPDATE 
									IQCustomer_DefaultSettings
							SET
									Value = @ID
							WHERE 
									_CustomerGuid = @CustomerGuid AND
									Field = 'IQPremium'	
					END -- EXIST CONDITION'S ELSE PART ENDS
												
				END		-- DEFAULT SEARCH CONDITION IF PART ENDS					
				ELSE
				BEGIN
					DELETE FROM
						IQCustomer_DefaultSettings
					WHERE															
						Value = @ID AND 
						Field = 'IQPremium' AND 
						_CustomerGuid = @CustomerGuid	
				END
									
				------------------

				DECLARE @Old_SearchRequestID as BIGINT
				SELECT 
							@Old_SearchRequestID = ID
					FROM 
							IQAgent_SearchRequest 
					WHERE 
							ClientGUID = @ClientGUID 
							AND _CustomerSavedSearchID = @ID
							--AND		IsActive = 1

				IF(@IsIQAgent = 0)
					BEGIN
						UPDATE IQAgent_SearchRequest SET IsActive = 0,ModifiedDate=getdate() WHERE ClientGUID = @ClientGUID AND ID = @Old_SearchRequestID;
					END
				
				
				---- Update IQ_Report based on IQAgent_SearchRequest.ID
				/*update IQ_Report
					set IsActive = 0
					from IQ_Report
					cross apply Reportrule.nodes('/Report/IQAgent/SearchRequest_Set/SearchRequest/ID') as ids(id)
					inner join IQAgent_SearchRequest
					ON IQAgent_SearchRequest.id = Ids.Id.value('.', 'int')
					AND IQAgent_SearchRequest.ClientGUID = IQ_Report.ClientGUID
					Where IQAgent_SearchRequest.ID = @Old_SearchRequestID */
				
				----
				
				IF(@IsIQAgent = 1)
				BEGIN
					DECLARE @Version int,@SearchRequestKey bigint

					SELECT 
							@Version = MAX(Query_Version)
					FROM 
							IQAgent_SearchRequest 
					WHERE 
							ClientGUID = @ClientGUID 
					AND _CustomerSavedSearchID = @ID

					IF(@Version IS NULL)
						BEGIN
							SET @Version = 0
						END
					ELSE
						BEGIN
							SET @Version = @Version + 1
						END
					
					UPDATE IQAgent_SearchRequest Set Query_Name = @Title Where _CustomerSavedSearchID = @ID
				
				IF(@IsIQagentInsertAllowed=0)
					BEGIN
						SET @IQAgentStatus = -4					
					END
				ELSE
					BEGIN	
						IF(@IsSearchTermEqual = 0)
							BEGIN
							
								IF(@Old_SearchRequestID is null)
								BEGIN
									INSERT INTO IQAgent_SearchRequest
									(
										[ClientGUID],
										[Query_Name],
										[Query_Version],
										[SearchTerm],
										[_CustomerSavedSearchID]
									)
									VALUES
									(
										@ClientGUID,
										@Title,
										'0',
										@IQPremiumSearchRequest,
										@ID
									)	
									
									SET @IQAgentStatus = SCOPE_IDENTITY()
									
									INSERT INTO	
										IQAgent_SearchRequest_History
										(
											_SearchRequestID,
											[Version],
											SearchRequest,
											Name
										)
										VALUES
										(
											@IQAgentStatus,
											@Version,
											@IQPremiumSearchRequest,
											@Title
										)	
										SELECT @SearchRequestKey = SCOPE_IDENTITY()
										Set @IQAgentStatus = @SearchRequestKey
										
								END
							ELSE -- ELSE OF Old_SearchRequestID is null
								BEGIN
										UPDATE IQAgent_SearchRequest
										SET IsActive = 1,
											SearchTerm = @IQPremiumSearchRequest,
											Query_Version = @Version,
											ModifiedDate= Getdate()
										WHERE ClientGUID = @ClientGUID AND ID = @Old_SearchRequestID;										
										Set @IQAgentStatus = @Old_SearchRequestID
										
										INSERT INTO	
										IQAgent_SearchRequest_History
										(
											_SearchRequestID,
											[Version],
											SearchRequest,
											Name
										)
										VALUES
										(
											@Old_SearchRequestID,
											@Version,
											@IQPremiumSearchRequest,
											@Title
										)	
										SELECT @SearchRequestKey = SCOPE_IDENTITY()
										Set @IQAgentStatus = @SearchRequestKey
										
								END
							END
						ELSE
							BEGIN
								UPDATE IQAgent_SearchRequest
								SET IsActive = 1									
								WHERE ClientGUID = @ClientGUID AND ID = @Old_SearchRequestID;
							END							
							
													
							--INSERT INTO	
							--	IQAgent_SearchRequest
							--	(
							--		ClientGUID,
							--		Query_Name,
							--		Query_Version,
							--		SearchTerm,
							--		_CustomerSavedSearchID
							--	)
							--	VALUES
							--	(
							--		@ClientGUID,
							--		@Title,
							--		@Version,
							--		@IQPremiumSearchRequest,
							--		@ID
							--	)
							
					END
				
					-- Now Update IQNotificationSettings Table's SearchRequestID With Newer One
				
			
			
					/*	Update IQNotificationSettings Set SearchRequestID = @IQAgentStatus
						Where SearchRequestID = @Old_SearchRequestID*/
					

				END
			

			    COMMIT TRANSACTION
				-----------------
				SET @OutputStatus = 0	
			END
			ELSE -- @OutPut Title condition's Else Starts
			BEGIN
				ROLLBACK TRANSACTION
				SET @OutputStatus = -2
			END -- @OutPut Title condition's Else Ends
					
		END		
		ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SET @OutputStatus = -1
			END
		SELECT @@ROWCOUNT as ROWAFFECTED
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		DECLARE @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit
				
		
		SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_IQCustomer_SavedSearch_Update',
				@ModifiedBy='usp_IQCustomer_SavedSearch_Update',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @OutputStatus = -3
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH	
				
		
    
    
END