CREATE PROCEDURE [dbo].[usp_IQAgent_GetLastIQSeqID_NEW]
	@SearchRequestID bigint,
	@MediaType varchar(2)
AS
BEGIN

SELECT [LastIQSeqID]
FROM [IQMediaGroup].[dbo].[IQAgent_LastIQSeqID_NEW] with (nolock)
WHERE _SearchRequestID = @SearchRequestID AND MediaType = @MediaType

END