CREATE PROCEDURE [dbo].[usp_v5_Instagram_GetClientIDAndSecret]
AS
BEGIN

	DECLARE @ClientID VARCHAR(150)
	DECLARE @ClientSecret VARCHAR(200)

	SELECT	@ClientID = Value
	FROM	IQClient_CustomSettings
	WHERE	_ClientGuid = '7722A116-C3BC-40AE-8070-8C59EE9E3D2A'
			AND Field = 'InstagramClientID'

	SELECT	@ClientSecret = Value
	FROM	IQClient_CustomSettings
	WHERE	_ClientGuid = '7722A116-C3BC-40AE-8070-8C59EE9E3D2A'
			AND Field = 'InstagramClientSecret'

	SELECT @ClientID as ClientID,
		   @ClientSecret as ClientSecret
END