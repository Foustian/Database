CREATE procedure [dbo].[usp_v4_IQ_Instagram_InsertSources]
	@SourceXml XML,
	@ClientGuid UNIQUEIDENTIFIER
AS
BEGIN
	INSERT INTO IQMediaGroup.dbo.IQ_Instagram (InstagramName, IsInstagramTag, CreatedDate, ModifiedDate, IsActive, IsDefault, _ClientGuid)
	SELECT	IG.Source.value('.','varchar(100)'),
			1,
			GETDATE(),
			GETDATE(),
			1,
			0,
			@ClientGuid
	FROM	@SourceXml.nodes('Instagram/Tags/Tag') as IG(Source)
	WHERE	NOT EXISTS (SELECT	NULL 
						FROM	IQMediaGroup.dbo.IQ_Instagram
						WHERE	InstagramName = IG.Source.value('.','varchar(100)')
								AND IsDefault = 0
								AND IsInstagramTag = 1
								AND _ClientGuid = @ClientGuid)

	UPDATE	IQMediaGroup.dbo.IQ_Instagram
	SET		IsActive = 1,
			ModifiedDate = GETDATE()
	WHERE	IsActive = 0
			AND EXISTS (SELECT	NULL
						FROM	@SourceXml.nodes('Instagram/Tags/Tag') as IG(Source)
						WHERE	InstagramName = IG.Source.value('.','varchar(100)')
								AND IsDefault = 0
								AND IsInstagramTag = 1
								AND _ClientGuid = @ClientGuid)

	INSERT INTO IQMediaGroup.dbo.IQ_Instagram (InstagramName, IsInstagramTag, CreatedDate, ModifiedDate, IsActive, IsDefault, _ClientGuid)
	SELECT	IG.Source.value('.','varchar(100)'),
			0,
			GETDATE(),
			GETDATE(),
			1,
			0,
			@ClientGuid
	FROM	@SourceXml.nodes('Instagram/Users/User') as IG(Source)
	WHERE	NOT EXISTS (SELECT	NULL 
						FROM	IQMediaGroup.dbo.IQ_Instagram
						WHERE	InstagramName = IG.Source.value('.','varchar(100)')
								AND IsDefault = 0
								AND IsInstagramTag = 0
								AND _ClientGuid = @ClientGuid)

	UPDATE	IQMediaGroup.dbo.IQ_Instagram
	SET		IsActive = 1,
			ModifiedDate = GETDATE()
	WHERE	IsActive = 0
			AND EXISTS (SELECT	NULL
						FROM	@SourceXml.nodes('Instagram/Users/User') as IG(Source)
						WHERE	InstagramName = IG.Source.value('.','varchar(100)')
								AND IsDefault = 0
								AND IsInstagramTag = 0
								AND _ClientGuid = @ClientGuid)
END
