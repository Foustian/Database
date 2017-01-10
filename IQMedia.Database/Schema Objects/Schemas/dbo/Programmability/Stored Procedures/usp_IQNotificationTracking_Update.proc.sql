-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_IQNotificationTracking_Update]

	@IQNotificationTrackingKey bigint

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	UPDATE	IQNotificationTracking
	SET
			Processed_Flag = 1,
			Processed_DateTime = GETDATE()
	WHERE
			IQNotificationTrackingKey = @IQNotificationTrackingKey
	
END


