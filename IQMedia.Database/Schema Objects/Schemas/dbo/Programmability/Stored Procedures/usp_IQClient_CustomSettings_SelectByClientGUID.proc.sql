-- =============================================
-- Create date: 11/4/2012
-- Description:	Get IQAdvancesetting by ClientGUID
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQClient_CustomSettings_SelectByClientGUID] 
@ClientGUID uniqueidentifier
	
AS
BEGIN
	
	SET NOCOUNT ON;
	Select
			Value as 'IQAdvancedSettings'
	From
			IQClient_CustomSettings
	Where
			IQClient_CustomSettings._ClientGuid=@ClientGUID  AND
			IQClient_CustomSettings.Field ='IQAdvancedSettings'
	
	
END
