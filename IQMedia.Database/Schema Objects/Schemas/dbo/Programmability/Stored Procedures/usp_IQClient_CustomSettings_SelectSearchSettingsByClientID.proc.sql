
CREATE PROCEDURE [dbo].[usp_IQClient_CustomSettings_SelectSearchSettingsByClientID]	
(
	@ClientID		bigint
)
AS
BEGIN

	SET NOCOUNT ON;
	
	Select
			Value as 'SearchSettings'
	From
			IQClient_CustomSettings
				inner join Client
					on IQClient_CustomSettings._ClientGuid=Client.ClientGuid
	Where
			Client.IsActive = 1 AND 
			Client.ClientKey=@ClientID  AND
			IQClient_CustomSettings.Field ='SearchSettings'
END
