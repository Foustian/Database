CREATE PROCEDURE [dbo].[usp_v5_Client_AddToAnewstip]
	@ClientKey BIGINT,
	@AnewstipClientID BIGINT
AS
BEGIN
	UPDATE IQMediaGroup.dbo.Client
	SET AnewstipClientID = @AnewstipClientID
	WHERE ClientKey = @ClientKey
END
