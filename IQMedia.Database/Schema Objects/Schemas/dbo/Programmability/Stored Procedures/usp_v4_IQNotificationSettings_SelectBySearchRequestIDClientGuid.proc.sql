CREATE PROCEDURE [dbo].[usp_v4_IQNotificationSettings_SelectBySearchRequestIDClientGuid]
	@SearchRequestID		BIGINT,
	@ClientGuid				UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*
	declare @gmt decimal(18,2),@dst decimal(18,2)
	Select
			@gmt=Client.gmt
	From
			Client
	WHERe
			ClientGUID = @ClientGuid and IsActive = 1

	*/

	SELECT	
			distinct
			IQNotificationSettings.IQNotificationKey,
			IQNotificationSettings.Frequency,
			Convert(varchar(max),IQNotificationSettings.Notification_Address) as Notification_Address,
			Convert(varchar(max),IQNotificationSettings.MediaType) as MediaType,
			Convert(varchar(max),IQNotificationSettings.SearchRequestList) as SearchRequestList,
			IQNotificationSettings.[DayOfWeek],
			--dateadd(hour,@gmt, MAX(IQNotificationSettings.[Time])) as [Time]
			IQNotificationSettings.[Time],
			(SELECT ', '+ Query_Name from IQAgent_SearchRequest inner join IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as a(b) on ID =   a.b.value('.','bigint') and  IQAgent_SearchRequest.IsActive = 1 and IQAgent_SearchRequest.ClientGUID = @ClientGuid for xml path(''))
	
	FROM	IQNotificationSettings cross apply IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as id(req)
	
	INNER JOIN IQAgent_SearchRequest
	ON		id.req.value('.','bigint') = IQAgent_SearchRequest.ID
	AND		IQNotificationSettings.ClientGuid = IQAgent_SearchRequest.ClientGuid
	AND		IQAgent_SearchRequest.IsActive = 1
	AND		IQNotificationSettings.IsActive = 1
	
	WHERE	
		IQAgent_SearchRequest.ID = @SearchRequestID
		AND		IQAgent_SearchRequest.ClientGuid = @ClientGuid
END
