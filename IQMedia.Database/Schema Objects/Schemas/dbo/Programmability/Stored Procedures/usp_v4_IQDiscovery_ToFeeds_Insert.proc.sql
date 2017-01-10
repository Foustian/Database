CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_ToFeeds_Insert]
	@ID bigint output,
	@SearchRequestID bigint,
	@MediaXml xml,
	@ClientGuid uniqueidentifier,
	@CustomerGuid uniqueidentifier,
	@ReportID	bigint
AS
BEGIN

	IF exists(Select 1 From IQAgent_SearchRequest Where ID=@SearchRequestID AND ClientGUID=@ClientGUID AND IsActive=1)
	BEGIN
		Insert into IQDiscovery_ToFeeds
	(
		MediaXml,
		ClientGuid,
		CustomerGuid,
		_IQAgentSearchRequestID,
		_ReportID,
		CreatedDate,
		ModifiedDate,
		IsActive
	)

	values
	(
		@MediaXml,
		@ClientGuid,
		@CustomerGuid,
		@SearchRequestID,
		@ReportID,
		GETDATE(),
		GETDATE(),
		1
	)

		SET @ID = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SET @ID=-1
	END
END