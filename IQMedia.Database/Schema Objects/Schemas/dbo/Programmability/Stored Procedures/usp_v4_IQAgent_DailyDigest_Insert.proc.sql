CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DailyDigest_Insert]
	@AgentXml xml,
	@TimeOfDay time,
	@EmailAddress varchar(max),
	@_ReportImageID bigint,
	@ClientGuid uniqueidentifier,
	@Status bigint output
AS
BEGIN
	--DECLARE @IQAgents Table(ID bigint)
	--DECLARE @Emails Table(Email varchar(500))

	SET @AgentXml = (SELECT a.b.value('.','bigint') FROM @AgentXml.nodes('/IQAgentList/IQAgent') a(b) order by a.b.value('.','bigint') for xml path('IQAgent'),root('IQAgentList'))
	SET @EmailAddress = STUFF((SELECT	';' + RTRIM(LTRIM(SplitTbl.Items)) FROM Split(@EmailAddress,';') as SplitTbl order by RTRIM(LTRIM(SplitTbl.Items)) for xml path('')),1,1,'')

	DECLARE @tmpDigest table(ID bigint,AgentXml xml,EmailAddress varchar(max))

	insert into @tmpDigest
	SELECT 
		ID,
		(SELECT a.b.value('.','bigint') FROM IQAgent_DailyDigest.AgentXml.nodes('IQAgentList/IQAgent') as a(b) order by a.b.value('.','bigint') for xml path('IQAgent'),root('IQAgentList')),
		STUFF((SELECT	';' + RTRIM(LTRIM(SplitTbl.Items)) FROM Split(IQAgent_DailyDigest.EmailAddress,';') as SplitTbl order by RTRIM(LTRIM(SplitTbl.Items)) for xml path('')),1,1,'')

	FROM
		IQAgent_DailyDigest WITH (NOLOCK)
	WHERE
		IQAgent_DailyDigest.IsActive = 1
		AND IQAgent_DailyDigest._ClientGuid = @ClientGuid


	IF NOT EXISTS(SELECT ID FROM @tmpDigest WHERE CONVERT(nvarchar(max),AgentXml) = CONVERT(nvarchar(max),@AgentXml) and EmailAddress = @EmailAddress)
    BEGIN

		declare @gmt decimal(18,2)
		Select
				@gmt=Client.gmt
		From
				Client
		Where
				ClientGUID = @ClientGuid

		INSERT INTO IQAgent_DailyDigest
		(
			EmailAddress,
			AgentXml,
			TimeOfDay,
			_ReportImageID,
			_ClientGuid,
			CreatedDate,
			ModifiedDate,
			IsActive	
		)
		values
		(
			@EmailAddress,
			@AgentXml,
			dateadd(hour,-@gmt, @TimeOfDay),
			@_ReportImageID,
			@ClientGuid,
			GETDATE(),
			GETDATE(),
			1
		)

		SET @Status = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SET @Status = -1
	END
END