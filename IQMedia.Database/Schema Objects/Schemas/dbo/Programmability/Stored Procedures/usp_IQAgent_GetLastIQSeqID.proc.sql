CREATE PROCEDURE [dbo].[usp_IQAgent_GetLastIQSeqID]
	@SearchRequestID bigint,
	@MediaType varchar(2)
AS
BEGIN

SELECT [LastIQSeqID]
FROM [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID] with (nolock)
WHERE _SearchRequestID = @SearchRequestID AND MediaType = @MediaType

END