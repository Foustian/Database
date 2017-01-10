
CREATE PROCEDURE [dbo].[usp_IQClient_UGCMap_SelectByClientGUID]
(
	@ClientGUID		uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	
	Select
			IQClient_UGCMap.AutoClip_Status,
			IQCore_Source.SourceID
	From
			IQClient_UGCMap
				inner join IQCore_Source
					on IQClient_UGCMap.SourceGUID=[IQCore_Source].[Guid]
	Where
			ClientGUID=@ClientGUID and
			IQClient_UGCMap.IsActive=1 
			


END
