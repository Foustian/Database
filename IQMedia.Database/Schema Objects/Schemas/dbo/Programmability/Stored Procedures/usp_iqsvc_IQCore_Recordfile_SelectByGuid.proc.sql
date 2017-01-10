CREATE PROCEDURE [dbo].[usp_iqsvc_IQCore_Recordfile_SelectByGuid]
	@Guid	uniqueidentifier
AS
BEGIN
	SELECT IQCore_Recordfile.[Guid] FROM IQCore_Recordfile Where [Guid] = @Guid
END