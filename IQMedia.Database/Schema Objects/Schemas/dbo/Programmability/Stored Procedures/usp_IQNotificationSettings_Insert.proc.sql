-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- [dbo].[usp_IQNotificationSettings_Insert] 13,'Email','bb@bb.com','Immediate',NULL

CREATE PROCEDURE [dbo].[usp_IQNotificationSettings_Insert] 
	@SearchRequestID bigint,
	@TypeofEntry varchar(10),
	@Notification_Address varchar(50),
	@Frequency varchar(25),
	@IQNotificationKey int output
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @AllowedNotification int
	Select @AllowedNotification =  isnull((Select Value from IQClient_CustomSettings where Field = 'TotalNoOfIQNotification' and _clientGUID = (Select ClientGUID from IQAgent_SearchRequest Where ID = @SearchRequestID)),(SELECT IQClient_CustomSettings.Value FROM IQClient_CustomSettings WHERE _ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) AND Field ='TotalNoOfIQNotification'))
	
	Declare @NotificationCount int
	Select @NotificationCount = COUNT(*) from IQNotificationSettings where SearchRequestID = @SearchRequestID and IsActive = 1
	
	print 'NOTIFICATION:' + CAST(@NotificationCount	 AS VARCHAR(10))
	PRINT '@AllowedNotification' + CAST(@AllowedNotification	 AS VARCHAR(10))
			
	if @NotificationCount < @AllowedNotification
		Begin
	
			DECLARE @Count int
			SELECT @Count = COUNT(*) FROM IQNotificationSettings 
			WHERE SearchRequestID = @SearchRequestID and Notification_Address = @Notification_Address AND Frequency = @Frequency
									 AND IsActive = 1 
			
    
			IF @Count = 0 
				BEGIN 
				
					-- Check if Same Record with Notification_Address and Frequency and IsActive = 0 is exist or not.
					-- If Exists then instead of insert just make active that record
					
					SELECT @IQNotificationKey = IQNotificationKey FROM IQNotificationSettings 
					WHERE Notification_Address = @Notification_Address AND Frequency = @Frequency AND IsActive = 0 
						AND SearchRequestID = @SearchRequestID
					
					IF @IQNotificationKey Is Not Null AND @IQNotificationKey > 0 
						BEGIN
							UPDATE IQNotificationSettings SET IsActive = 1 WHERE IQNotificationKey = @IQNotificationKey
						END
					ELSE
						BEGIN
							INSERT INTO	
								IQNotificationSettings
								(
									SearchRequestID,
									TypeofEntry,
									Notification_Address,
									Frequency
							
								)
								VALUES
								(
									@SearchRequestID,
									@TypeofEntry,
									@Notification_Address,
									@Frequency
								)
							SELECT @IQNotificationKey = SCOPE_IDENTITY()
						END
				END
				
			ELSE -- @Count = 0's else condition
				BEGIN
					SET @IQNotificationKey=-2
				END
			
		END
		ELSE
			SET @IQNotificationKey=-1
END

