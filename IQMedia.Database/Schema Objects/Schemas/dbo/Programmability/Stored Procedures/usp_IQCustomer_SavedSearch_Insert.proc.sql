-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_Insert]
	@CustomerGuid	uniqueidentifier,
	@IQPremiumSearchRequest	xml,
	@Title varchar(150),
	@Description varchar(500),
	@CategoryGuid uniqueidentifier,
	@IsDefualtSearch bit,
	@IsIQAgent bit,
	@ClientGUID		uniqueidentifier,
	@OutputStatus int output,
	@OutputTitle varchar(150) output,
	@OutputID bigint output,
	@IQAgentStatus int output
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRANSACTION
	BEGIN TRY

		IF NOT EXISTS(SELECT Title From IQCustomer_SavedSearch Where CustomerGuid = @CustomerGuid AND Title = @Title AND IsActive = 1)
		BEGIN
		
				DECLARE @IsIQagentInsertAllowed bit
				IF(@IsIQAgent = 1)
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
					SET @IsIQagentInsertAllowed = 0
				END
					
			SELECT @OutputTitle = Title From IQCustomer_SavedSearch Where CustomerGuid = @CustomerGuid AND convert(nvarchar(max),IQPremiumSearchRequest) = convert(nvarchar(max),@IQPremiumSearchRequest) AND IsActive = 1
			IF(ISNULL(@OutputTitle,'') = '')
			BEGIN
				--DECLARE @SearchIndex bigint
	
				INSERT INTO IQCustomer_SavedSearch
				(
					CustomerGuid,
					IQPremiumSearchRequest,
					Title,
					[Description],
					CategoryGuid,
					IsIQAgent,
					CreatedDate,
					ModifiedDate,
					IsActive
				)
				VALUES
				(
					@CustomerGuid,
					@IQPremiumSearchRequest,
					@Title,
					@Description,
					@CategoryGuid,
					@IsIQagentInsertAllowed,
					GETDATE(),
					GETDATE(),
					1
				)
			
				SET @OutputID = SCOPE_IDENTITY()
			
				IF(@IsDefualtSearch = 1)
				BEGIN
				
					INSERT INTO IQCustomer_DefaultSettings	
					(Field,Value,_CustomerGuid)	
						Select  TOP 1
							'IQPremium',
							@OutputID,
							@CustomerGuid
						FROM 
							IQCustomer_SavedSearch IQCS
								LEFT OUTER JOIN IQCustomer_DefaultSettings IQCD
								ON IQCD.Field = 'IQPremium' 
								AND IQCS.CustomerGuid = IQCD._CustomerGuid
							
								where IQCD._CustomerGuid IS NULL							
									AND IQCS.CustomerGuid =@CustomerGuid
							
					UPDATE 
							IQCustomer_DefaultSettings
					SET
							Value = @OutputID
					WHERE 
							_CustomerGuid = @CustomerGuid AND
							Field = 'IQPremium'	
				
				END

				IF(@IsIQAgent = 1)
				BEGIN
								
				IF(@IsIQagentInsertAllowed=0)
					BEGIN
						SET @IQAgentStatus = -4					
					END
				ELSE
					BEGIN
					INSERT INTO
						IQAgent_SearchRequest
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
							@OutputID
						)	
						
						SET @IQAgentStatus = SCOPE_IDENTITY()
						
						INSERT INTO
						IQAgent_SearchRequest_History
						(
							[_SearchRequestID],
							[Version],							
							[SearchRequest],
							Name
							
						)
						VALUES
						(
							@IQAgentStatus,
							'0',
							@IQPremiumSearchRequest,
							@Title
						)					

						
						
					END				
					
				END

				COMMIT TRANSACTION
				SET @OutputStatus = 0
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SET @OutputStatus = -2
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION
			SET @OutputStatus = -1
		END
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
				@CreatedBy='usp_IQCustomer_SavedSearch_Insert',
				@ModifiedBy='usp_IQCustomer_SavedSearch_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
				
		SET @OutputStatus = -3
		
		EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@ModifiedBy,@CreatedDate,@ModifiedDate,@IsActive,@IQMediaGroupExceptionKey output
		
	END CATCH

END
