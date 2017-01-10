-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQNotificationSettings_Update]

	@IQNotificationKey int,
	@Notification_Address varchar(50),
	@Frequency varchar(25),
	@SearchRequestID int

AS
BEGIN

	SET NOCOUNT OFF;

	DECLARE @Count int
		SELECT @Count = COUNT(*) FROM IQNotificationSettings 
		WHERE Notification_Address = @Notification_Address and IQNotificationKey <> @IQNotificationKey AND SearchRequestID = @SearchRequestID
										AND Frequency = @Frequency And IsActive = 1
     
			IF @Count = 0 
			BEGIN 
				UPDATE
					IQNotificationSettings
				SET
				
				Notification_Address = @Notification_Address,
				Frequency = @Frequency
				
				WHERE
				
				IQNotificationKey = @IQNotificationKey
		end
END
