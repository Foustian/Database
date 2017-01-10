-- =============================================
-- Author:		<Author,,Name>
-- Create date: 22 July 2013
-- Description:	Select record based on client GUID
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_SelectByClientGUID]
	@ClientGuid UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
			IQClient_UGCMap.AutoClip_Status, 
			IQCore_Source.SourceID 
	FROM	IQClient_UGCMap 

	INNER JOIN IQCore_Source 
	ON IQClient_UGCMap.SourceGUID=[IQCore_Source].[Guid] 
	
	WHERE 	ClientGUID=@ClientGUID 
	AND		IQClient_UGCMap.IsActive=1
	


END