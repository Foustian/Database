CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectImmediate]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		[IQAgent_SearchRequest].[ID] as SearchRequestID, 
		[Query_Name] as QueryName, 
		[Query_Version] as QueryVersion, 
		[SearchTerm],
		[TBLA].[Frequency] as Frequency,
		[iQMediaGroup].[dbo].[IQAgent_SearchRequest].[ClientGUID] as ClientGUID
		FROM  [iQMediaGroup].[dbo].[IQAgent_SearchRequest] with (nolock)
			inner join [iQMediaGroup].[dbo].[Client] with (nolock) 
			on [iQMediaGroup].[dbo].[IQAgent_SearchRequest].[ClientGUID] = [iQMediaGroup].[dbo].[Client].[ClientGUID]
			left outer join
			(select distinct a.b.value('.[1]', 'int') as SRID, Frequency 
			from [IQMediaGroup].[dbo].[IQNotificationSettings]
			cross apply [SearchRequestList].nodes('//SearchRequestID') as a(b)
			where [IsActive] = 1 ) TBLA
			on [iQMediaGroup].[dbo].[IQAgent_SearchRequest].[ID] = [TBLA].[SRID]
		WHERE [iQMediaGroup].[dbo].[IQAgent_SearchRequest].[IsActive]=1
		and ([TBLA].[Frequency] = 'Immediate' OR [Client].[IQAgentGroup] = 'C')
		ORDER BY [IQAgent_SearchRequest].ID
END