-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- EXEC [dbo].[usp_IQNotificationTracking_SelectByCommunicationFlag]

CREATE PROCEDURE [dbo].[usp_IQNotificationTracking_SelectByCommunicationFlag]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- DECLARE AND CREATE Temp table to hold data so that we dont need to make query two times.
	-- 1. Update Commnunication_Flag 1 into IQAgentResults table.
	-- 2. To insert record into IQNotificationTracking table.
	
	DECLARE @IQNotificationSettings AS TABLE 
	(
		SearchRequestID			bigint,
		TypeofEntry				varchar(10),
		Notification_Address	varchar(50),
		Frequency				varchar(25)
	)
		
	
	-- Fill Temp table with results from IQNotificationSettings and IQResults table.
	
	INSERT INTO @IQNotificationSettings 

	SELECT	
			DISTINCT
			IQNotificationSettings.SearchRequestID,
			IQNotificationSettings.TypeofEntry,
			IQNotificationSettings.Notification_Address,
			IQNotificationSettings.Frequency
	FROM 
	IQAgentResults 
	
	INNER JOIN IQNotificationSettings 
	ON IQAgentResults.SearchRequestID = IQNotificationSettings.SearchRequestID
	AND	IQAgentResults.Communication_flag IS NULL
	AND	IQNotificationSettings.IsActive = 1
	

	
	
	-- Use first time use resultset to insert Record into IQNotificationTracking table.
	
	INSERT INTO IQNotificationTracking 
				(
					SearchRequestID,
					TypeofEntry,
					Notification_Address,
					Frequency
				)
	SELECT 
			SearchRequestID,
			TypeofEntry,
			Notification_Address,
			Frequency 
	FROM 
			@IQNotificationSettings
	
	
	-- Second time use resultset to update Communication_flag = 1 into IQAgentResults table.
	
	UPDATE 
			IQAgentResults 
		SET 
			Communication_flag = 1,
			ModifiedDate = GETDATE()
			
	FROM 
			IQAgentResults INNER JOIN @IQNotificationSettings AS IQNotificationSettings_Table
	ON IQAgentResults.SearchRequestID = IQNotificationSettings_Table.SearchRequestID 
	AND IQAgentResults.Communication_flag IS NULL
	
	
	-- Finally Select From IQNotificationTracking Table Which are UnProcessed
	
	SELECT 
			IQNotificationTracking.IQNotificationTrackingKey,
			IQNotificationTracking.SearchRequestID,
			IQAgent_SearchRequest.Query_Name,
			IQNotificationTracking.TypeofEntry,
			IQNotificationTracking.Notification_Address,
			IQNotificationTracking.Frequency,
			IQNotificationTracking.Processed_Flag,
			IQNotificationTracking.Processed_DateTime
			
	FROM	IQNotificationTracking
			
	INNER JOIN IQAgent_SearchRequest
	ON	IQNotificationTracking.SearchRequestID = IQAgent_SearchRequest.ID
	AND IQAgent_SearchRequest.IsActive = 1
	
	WHERE
			IQNotificationTracking.Processed_Flag IS NULL 
	AND		IQNotificationTracking.Processed_DateTime IS NULL
	AND		IQNotificationTracking.IsActive = 1
	
END


/****** Object:  StoredProcedure [dbo].[usp_IQNotificationTracking_Update]    Script Date: 05/12/2010 19:25:38 ******/
SET ANSI_NULLS ON
