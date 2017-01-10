CREATE PROCEDURE [dbo].[usp_v5_Instagram_CheckClientAccess]
	@ClientGuid UNIQUEIDENTIFIER,
	@HasAccess BIT OUTPUT
AS
BEGIN

	IF (SELECT ISNULL(InstagramAuthToken, '') FROM IQ_InstagramClients WHERE _ClientGuid = @ClientGuid AND IsActive = 1 AND IsTokenExpired = 0) != ''
	  BEGIN
		SET @HasAccess = 1
	  END
	ELSE
	  BEGIN
		SET @HasAccess = 0
	  END

END