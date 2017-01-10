CREATE PROCEDURE [dbo].[usp_v4_IQNotificationSettings_Update]
	@ClientGuid					UNIQUEIDENTIFIER,
	@SearchRequestList			XML,
	@IQNotificationKey			BIGINT,
	@Notification_Address		xml,
	@Frequency					VARCHAR(25),
	@MediumType					xml,
	@DayOfWeek					int,				
	@Time						Time,
	@_ReportImageID				bigint,			
	@UseRollup					bit,
	@Output						BIGINT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @SearchRequestList = (SELECT a.b.value('.','bigint') FROM @SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') a(b) order by a.b.value('.','bigint') for xml path('SearchRequestID'),root('SearchRequestIDList'))
	SET @Notification_Address = (SELECT a.b.value('.','varchar(500)') FROM @Notification_Address.nodes('EmailAddressList/EmailAddress') a(b) order by a.b.value('.','varchar(500)') for xml path('EmailAddress'),root('EmailAddressList'))

	DECLARE @tmpDigest table(ID bigint,AgentXml xml,EmailAddress xml,Frequency varchar(20))

	insert into @tmpDigest
	SELECT 
		IQNotificationKey,
		(SELECT a.b.value('.','bigint') FROM  IQNotificationSettings.SearchRequestList.nodes('SearchRequestIDList/SearchRequestID') as a(b) order by a.b.value('.','bigint') for xml path('SearchRequestID'),root('SearchRequestIDList')),
		(SELECT a.b.value('.','varchar(500)') FROM IQNotificationSettings.Notification_Address.nodes('EmailAddressList/EmailAddress') a(b) order by a.b.value('.','varchar(500)') for xml path('EmailAddress'),root('EmailAddressList')),
		IQNotificationSettings.Frequency
	FROM
		IQNotificationSettings WITH (NOLOCK)
	WHERE
		IQNotificationSettings.IsActive = 1
		AND IQNotificationKey != @IQNotificationKey

		IF NOT EXISTS(SELECT ID FROM @tmpDigest WHERE CONVERT(nvarchar(max),AgentXml) = CONVERT(nvarchar(max),@SearchRequestList) and CONVERT(nvarchar(max),EmailAddress) = CONVERT(nvarchar(max),@Notification_Address) and  Frequency = @Frequency)
		BEGIN
			
			/*
			IF(@Time IS NOT NULL)
			BEGIN
				declare @gmt decimal(18,2)
				Select
								@gmt=Client.gmt
				FROM		
						Client
				WHERE
						ClientGUID  = @ClientGuid
						and IsActive = 1

				SET @Time = dateadd(hour,-@gmt, @Time)
			END
			*/
			DECLARE @ReportTypeID bigint 
			SELECT @ReportTypeID = IQ_ReportType.ID FROM IQ_ReportType WHERE  IQ_ReportType.[Identity] = @Frequency

			UPDATE dbo.IQNotificationSettings
			SET		
					Notification_Address= @Notification_Address,
					Frequency = @Frequency,
					MediaType = @MediumType,
					[Time] = @Time,
					[DayOfWeek] = @DayOfWeek,
					_ReportImageID = @_ReportImageID,
					_ReportTypeID = @ReportTypeID,
					SearchRequestList = @SearchRequestList,
					ModifiedDate = GETDATE(),
					ModifiedBy = 'System',
					UseRollup = @UseRollup
			FROM 
					IQNotificationSettings 
						inner join Client 
							on IQNotificationSettings.ClientGuid = Client.ClientGUID
							and Client.ClientGUID  = @ClientGuid
			WHERE	IQNotificationKey = @IQNotificationKey
					
				
			SET		@Output = @IQNotificationKey
			
		END
	ELSE
		BEGIN
			SET @Output = -1
		END
	
END