CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DailyDigest_Update]
	@ID bigint,
	@AgentXml xml,
	@TimeOfDay time,
	@EmailAddress varchar(max),
	@_ReportImageID bigint,
	@ClientGuid uniqueidentifier,
	@Status bigint output
AS
BEGIN
	
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
		AND ID != @ID


	IF NOT EXISTS(SELECT ID FROM @tmpDigest WHERE CONVERT(nvarchar(max),AgentXml) = CONVERT(nvarchar(max),@AgentXml) and EmailAddress = @EmailAddress)
    BEGIN

		declare @gmt decimal(18,2)
		Select
				@gmt=Client.gmt
		From
				Client
		Where
				ClientGUID = @ClientGuid
		
		UPDATE 
				IQAgent_DailyDigest
		SET
				AgentXml = @AgentXml,
				TimeOfDay = dateadd(hour,-@gmt, @TimeOfDay),
				EmailAddress = @EmailAddress,
				_ReportImageID = @_ReportImageID,
				ModifiedDate = GETDATE()
		WHERE	
				ID = @ID
				and _ClientGuid = @ClientGuid

		SELECT @Status = @@ROWCOUNT
	END
	ELSE
	BEGIN
		SELECT @Status = -1
	END
END