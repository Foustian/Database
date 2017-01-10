CREATE PROCEDURE [dbo].[usp_v4_IQ_Google_CheckClientAccess]
	@ClientGuid UNIQUEIDENTIFIER,
	@HasAccess BIT OUTPUT
AS
BEGIN

	IF (SELECT ISNULL(GoogleAuthCode, '') FROM	IQ_GoogleClients WHERE	_ClientGuid = @ClientGuid AND IsActive = 1) != ''
	  BEGIN
		SET @HasAccess = 1
	  END
	ELSE
	  BEGIN
		SET @HasAccess = 0
	  END

END

