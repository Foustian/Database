CREATE PROCEDURE [dbo].[usp_v4_IQ_Google_GetClientID]
AS
BEGIN

	SELECT	Value AS ClientID
	FROM	IQClient_CustomSettings
	WHERE	_ClientGuid = '7722A116-C3BC-40AE-8070-8C59EE9E3D2A'
			AND Field = 'GoogleClientID'

END
