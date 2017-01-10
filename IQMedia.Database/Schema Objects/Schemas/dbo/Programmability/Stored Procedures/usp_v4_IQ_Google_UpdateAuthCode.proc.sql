CREATE PROCEDURE [dbo].[usp_v4_IQ_Google_UpdateAuthCode]
	@ClientGuid UNIQUEIDENTIFIER,
	@AuthCode VARCHAR(250)
AS
BEGIN

	IF (SELECT 1 FROM IQ_GoogleClients WHERE _ClientGUID = @ClientGuid AND IsActive = 1) IS NULL
	  BEGIN
		INSERT INTO IQ_GoogleClients (_ClientGUID, GoogleAuthCode, CreatedDate, ModifiedDate, IsActive)
		VALUES (@ClientGuid, @AuthCode, GETDATE(), GETDATE(), 1)
	  END
	ELSE
	  BEGIN
		-- Any time an auth code is updated, the current access token is invalidated, so set it and correpsonding fields to null
		UPDATE	IQ_GoogleClients
		SET		GoogleAuthCode = @AuthCode,
				GoogleAccessToken = NULL,
				LastUpdatedTokenDatetime = NULL,
				GoogleRefreshToken = NULL,
				ModifiedDate = GETDATE()
		WHERE	_ClientGUID = @ClientGuid
				AND IsActive = 1
	  END

END

