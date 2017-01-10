CREATE PROCEDURE [dbo].[usp_v4_IQNotificationSettings_Delete]
(
	@IQNotificationKey bigint,
	@ClientGuid uniqueidentifier
)
AS
BEGIN	
	UPDATE 
		IQNotificationSettings 
	SET 
		IQNotificationSettings.IsActive = 0 ,
		IQNotificationSettings.ModifiedDate = GETDATE()
	FROM   
		IQNotificationSettings INNER JOIN IQAgent_SearchRequest
			ON IQNotificationSettings.SearchRequestID = IQAgent_SearchRequest.ID
	WHERE	
		IQNotificationKey = @IQNotificationKey
		AND ClientGUID = @ClientGuid
		and 
END