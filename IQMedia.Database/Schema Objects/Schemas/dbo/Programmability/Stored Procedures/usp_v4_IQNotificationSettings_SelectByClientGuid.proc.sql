CREATE PROCEDURE [dbo].[usp_v4_IQNotificationSettings_SelectByClientGuid]
	@ClientGuid uniqueidentifier,
	@PageNumner	int,
	@PageSize	int,
	@TotalResults int output
AS
BEGIN

	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	SELECT 
			@TotalResults = COUNT(*)
	FROM 
			IQNotificationSettings
				inner join Client
					on Client.ClientGUID = IQNotificationSettings.ClientGuid
	WHERE
			Client.ClientGUID = @ClientGuid
			and Client.IsActive = 1
			and IQNotificationSettings.IsActive = 1
			and (SELECT ', '+ Query_Name from IQAgent_SearchRequest inner join IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as a(b) on ID =   a.b.value('.','bigint') and  IQAgent_SearchRequest.IsActive = 1 and IQAgent_SearchRequest.ClientGUID = @ClientGuid for xml path('')) IS NOT NULL

	;With tempNotification AS(
		SELECT	
				ROW_NUMBER() OVER (ORDER BY IQNotificationSettings.IQNotificationKey DESC) as RowNum,
				IQNotificationSettings.IQNotificationKey,
				IQNotificationSettings.Frequency,
				Convert(varchar(max),IQNotificationSettings.Notification_Address) as Notification_Address,
				Convert(varchar(max),IQNotificationSettings.MediaType) as MediaType,
				Convert(varchar(max),IQNotificationSettings.SearchRequestList) as SearchRequestList,
				IQNotificationSettings.[DayOfWeek],
				IQNotificationSettings.[Time],
				(SELECT ', '+ Query_Name from IQAgent_SearchRequest inner join IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as a(b) on ID =   a.b.value('.','bigint') and  IQAgent_SearchRequest.IsActive = 1 and IQAgent_SearchRequest.ClientGUID = @ClientGuid for xml path('')) as IQAgentNames,
				IQNotificationSettings.UseRollup
	
		FROM	IQNotificationSettings 
				INNER JOIN Client
					ON IQNotificationSettings.ClientGuid = Client.ClientGUID
					and Client.ClientGUID = @ClientGuid
					and Client.IsActive = 1
					and IQNotificationSettings.IsActive = 1
					and (SELECT ', '+ Query_Name from IQAgent_SearchRequest inner join IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as a(b) on ID =   a.b.value('.','bigint') and  IQAgent_SearchRequest.IsActive = 1 and IQAgent_SearchRequest.ClientGUID = @ClientGuid for xml path('')) IS NOT NULL
	)
	SELECT 
			IQNotificationKey,
			Frequency,
			Notification_Address,
			MediaType,
			SearchRequestList,
			[DayOfWeek],
			[Time],
			IQAgentNames,
			UseRollup

	FROM
			tempNotification
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
	ORDER BY  RowNum

	
END