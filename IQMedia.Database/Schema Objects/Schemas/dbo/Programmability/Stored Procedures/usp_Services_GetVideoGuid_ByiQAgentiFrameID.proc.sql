-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Services_GetVideoGuid_ByiQAgentiFrameID]
	@iQAgentiFrameID uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DataModelType VARCHAR(10), @IQAgentResultID BIGINT, @Expiry_Date DATETIME
    
    IF((Select IQAgentResultID from IQAgentiFrame where Guid = @iQAgentiFrameID) is Not Null)
		Begin
			SELECT	@DataModelType = DataModelType,
					@IQAgentResultID = IQAgentResultID,
					@Expiry_Date = Expiry_Date
			FROM	IQMediaGroup.dbo.IQAgentIFrame
			WHERE	Guid = @iQAgentiFrameID
					AND IsActive = 1
			
			IF @DataModelType = 'TV'
			  BEGIN
				IF EXISTS (SELECT 1 FROM IQAgent_TVResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
				  BEGIN
					 Select 
						Case 
							When 
								@Expiry_Date > Getdate()
							Then    
								RL_VideoGUID 
							Else
								Null
						END
					From
						IQAgent_TVResults WITH (NOLOCK)			
					WHERE ID = @IQAgentResultID
						AND IsActive = 1
				  END
				ELSE
				  BEGIN
					 Select 
						Case 
							When 
								@Expiry_Date > Getdate()
							Then    
								RL_VideoGUID 
							Else
								Null
						END
					From
						IQAgent_TVResults_Archive WITH (NOLOCK)			
					WHERE ID = @IQAgentResultID
						AND IsActive = 1
				  END
			  END
			ELSE IF @DataModelType = 'IQR'
			  BEGIN
				IF EXISTS (SELECT 1 FROM IQAgent_RadioResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
				  BEGIN
					 Select 
						Case 
							When 
								@Expiry_Date > Getdate()
							Then    
								Guid 
							Else
								Null
						END
					From
						IQAgent_RadioResults WITH (NOLOCK)			
					WHERE ID = @IQAgentResultID
						AND IsActive = 1
				  END
				ELSE
				  BEGIN
					 Select 
						Case 
							When 
								@Expiry_Date > Getdate()
							Then    
								Guid 
							Else
								Null
						END
					From
						IQAgent_RadioResults_Archive WITH (NOLOCK)			
					WHERE ID = @IQAgentResultID
						AND IsActive = 1
				  END
			  END
			ELSE
			  BEGIN
				SELECT NULL

				DECLARE @IQMediaGroupExceptionKey BIGINT,
						@ExceptionMessage VARCHAR(500) = 'Encountered unsupported DataModelType: ' + ISNULL(@DataModelType, 'NULL'),
						@CreatedBy VARCHAR(50) = 'usp_Services_GetVideoGuid_ByiQAgentiFrameID',
						@CreatedDate DATETIME = GETDATE()
		
				EXEC usp_IQMediaGroupExceptions_Insert '',@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
			  END		
		End
	Else
		Begin
		
			Select 
				Case 
					When 
						[Expiry_Date] > Getdate()
					Then    
						RawMediaGuid 
					Else
						Null
				END
				
			From
				 IQAgentiFrame
			Where
				IQAgentiFrame.[GUID] = @iQAgentiFrameID				
		
		END
END
