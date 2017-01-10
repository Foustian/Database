CREATE procedure [dbo].[usp_v4_IQ_FacebookProfile_Insert]
	@FBPageXml XML
AS
BEGIN
	INSERT INTO IQMediaGroup.dbo.IQ_FBProfile (FBPageID, FBLink, FBIsVerified, CreatedDate, ModifiedDate, IsActive, IsDefault)
	SELECT	FB.Page.value('ID[1]','bigint'),
			FB.Page.value('Page[1]','varchar(250)'),
			0,
			GETDATE(),
			GETDATE(),
			1,
			0
	FROM	@FBPageXml.nodes('Facebook/FBPages/FBPage') as FB(Page)
	WHERE	NOT EXISTS (SELECT	NULL 
						FROM	IQMediaGroup.dbo.IQ_FBProfile
						WHERE	FBPageID = FB.Page.value('ID[1]','bigint'))

	UPDATE	IQMediaGroup.dbo.IQ_FBProfile
	SET		IsActive = 1,
			ModifiedDate = GETDATE()
	WHERE	IsActive = 0
			AND EXISTS (SELECT	NULL
						FROM	@FBPageXml.nodes('Facebook/FBPages/FBPage') as FB(Page)
						WHERE	FBPageID = FB.Page.value('ID[1]','bigint'))
END


