-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQAgentiFrame_Insert] 
	@RawMediaGuid uniqueidentifier,
	@Expiry_Date datetime,
	@IQAgentResultID bigint,
	@DataModelType varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

	Declare @Status bit,
	@IQAgentiFrameID uniqueidentifier,
	@isValid bit,
	@RecordExists bit,
	@IsError bit = 0
	
	Set @RecordExists = 0
	Set @isValid = 0
	
	IF(@IQAgentResultID is Not Null)
		BEGIN		
			IF EXISTS(Select 1 From IQAgentiFrame Where iQAgentResultID = @IQAgentResultID and IsActive = 1 and DataModelType = @DataModelType)
				BEGIN
					Set @RecordExists = 1
				END

				IF @RawMediaGuid IS NULL
				  BEGIN
					IF @DataModelType = 'TV'
					  BEGIN
						IF EXISTS (SELECT 1 FROM IQAgent_TVResults WITH (NOLOCK) WHERE @IQAgentResultID = ID)
						  BEGIN
							SELECT	@RawMediaGuid = RL_VideoGUID
							FROM	IQAgent_TVResults WITH (NOLOCK)
							WHERE	@IQAgentResultID = ID
						  END
						ELSE
						  BEGIN
							SELECT	@RawMediaGuid = RL_VideoGUID
							FROM	IQAgent_TVResults_Archive WITH (NOLOCK)
							WHERE	@IQAgentResultID = ID
						  END
					  END
					ELSE IF @DataModelType = 'IQR'
					  BEGIN
						IF EXISTS (SELECT 1 FROM IQAgent_RadioResults WITH (NOLOCK) WHERE @IQAgentResultID = ID)
						  BEGIN
							SELECT	@RawMediaGuid = Guid
							FROM	IQAgent_RadioResults WITH (NOLOCK)
							WHERE	@IQAgentResultID = ID
						  END
						ELSE
						  BEGIN
							SELECT	@RawMediaGuid = Guid
							FROM	IQAgent_RadioResults_Archive WITH (NOLOCK)
							WHERE	@IQAgentResultID = ID
						  END
					  END
					ELSE
					  BEGIN
						SET @IsError = 1
					  END
				  END
		END
	ELSE
		BEGIN		
			IF EXISTS(Select 1 From IQAgentiFrame Where RawMediaGuid = @RawMediaGuid and IsActive = 1 and DataModelType = @DataModelType)
				BEGIN
					Set @RecordExists = 1
				END

				IF @DataModelType = 'TV'
				  BEGIN
					IF EXISTS (SELECT 1 FROM IQAgent_TVResults WITH (NOLOCK) WHERE @RawMediaGuid = RL_VideoGUID)
					  BEGIN
						SELECT	@IQAgentResultID = ID
						FROM	IQAgent_TVResults WITH (NOLOCK)
						WHERE	@RawMediaGuid = RL_VideoGUID
					  END
					ELSE
					  BEGIN
						SELECT	@IQAgentResultID = ID
						FROM	IQAgent_TVResults_Archive WITH (NOLOCK)
						WHERE	@RawMediaGuid = RL_VideoGUID
					  END
				  END
				ELSE IF @DataModelType = 'IQR'
				  BEGIN
					IF EXISTS (SELECT 1 FROM IQAgent_RadioResults WITH (NOLOCK) WHERE @RawMediaGuid = Guid)
					  BEGIN
						SELECT	@IQAgentResultID = ID
						FROM	IQAgent_RadioResults WITH (NOLOCK)
						WHERE	@RawMediaGuid = Guid
					  END
					ELSE
					  BEGIN
						SELECT	@IQAgentResultID = ID
						FROM	IQAgent_RadioResults_Archive WITH (NOLOCK)
						WHERE	@RawMediaGuid = Guid
					  END
				  END
				ELSE
				  BEGIN
					SET @IsError = 1
				  END
		END

	IF @IsError = 1
	  BEGIN
		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionMessage VARCHAR(500) = 'Encountered unsupported DataModelType: ' + ISNULL(@DataModelType, 'NULL'),
				@CreatedBy VARCHAR(50) = 'usp_IQAgentiFrame_Insert',
				@CreatedDate DATETIME = GETDATE()
		
		EXEC usp_IQMediaGroupExceptions_Insert '',@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	  END
	
	-- Make sure the video file is valid
	Select @isValid = Case [Status] When 'READY' Then 1 Else 0 End 
	From	IQCore_Recordfile With (NOLOCK)
	Where	Guid = @RawMediaGuid

	IF @isValid = 1
		BEGIN
			Set @Status = 0	

			IF @RecordExists = 0
				BEGIN
					Set @iQAgentiFrameID = NewID()
		    
					INSERT INTO IQAgentiFrame
					(
						[GUID],
						RawMediaGuid,
						[Expiry_Date],
						CreatedDate,
						IsActive,
						IQAgentResultID,
						DataModelType
					)
					VALUES
					(
						@iQAgentiFrameID,
						Case 
							When 
								@IQAgentResultID is Not Null
							Then 
								Null
						Else 
								@RawMediaGuid
						END,
						@Expiry_Date,
						getdate(),
						1,
						@IQAgentResultID,
						@DataModelType
					)	
				END
			ELSE
				BEGIN
					-- If a record already exists, just update its expiration date
					Select	@IQAgentiFrameID = [Guid]
					From	IQAgentiFrame
					Where	IsActive = 1 and
							DataModelType = @DataModelType and
							(IQAgentResultID = @IQAgentResultID or (@IQAgentResultID is null and RawMediaGuid = @RawMediaGuid))

					IF (Select [Expiry_Date] From IQAgentiFrame Where Guid = @IQAgentiFrameID) < @Expiry_Date
						BEGIN
							Update	IQAgentiFrame
							Set		[Expiry_Date] = @Expiry_Date
							Where	IsActive = 1 and
									DataModelType = @DataModelType and
									(IQAgentResultID = @IQAgentResultID or (@IQAgentResultID is null and RawMediaGuid = @RawMediaGuid))
						END
				END
		 END 
	 ELSE	
		BEGIN
			Update	IQAgentiFrame
			Set		[Expiry_Date] = DATEADD(DAY, -1, GETDATE()),
					IsActive = 0
			Where	IsActive = 1 and
					DataModelType = @DataModelType and
					(IQAgentResultID = @IQAgentResultID or (@IQAgentResultID is null and RawMediaGuid = @RawMediaGuid))
			
			Set @Status = 1
			Set @IQAgentiFrameID = NewID()
		END
 
	Select	@IQAgentiFrameID as 'IQAgentiFrameID',
			@Status as 'Status'
    
END
