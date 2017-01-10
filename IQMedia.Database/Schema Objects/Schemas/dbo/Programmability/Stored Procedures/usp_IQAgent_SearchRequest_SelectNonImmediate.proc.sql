CREATE PROCEDURE [dbo].[usp_IQAgent_SearchRequest_SelectNonImmediate]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		[IQAgent_SearchRequest].[ID] as SearchRequestID, 
		[Query_Name] as QueryName,
		[Query_Version] as QueryVersion, 
		[SearchTerm],
		[Frequency] as Frequency,
		[IQAgent_SearchRequest].[ClientGUID] as ClientGUID
		FROM  [iQMediaGroup].[dbo].[IQAgent_SearchRequest] with (nolock) 
			inner join [iQMediaGroup].[dbo].[Client] with (nolock) 
			on [iQMediaGroup].[dbo].[IQAgent_SearchRequest].[ClientGUID] = [iQMediaGroup].[dbo].[Client].[ClientGUID] 
		left outer join 
				(select distinct a.b.value('.[1]', 'int') as SRID , Frequency
					from [IQMediaGroup].[dbo].[IQNotificationSettings]
					cross apply [SearchRequestList].nodes('//SearchRequestID') as a(b)
					where Frequency <> 'Immediate' and IsActive = 1) as Tmp
		on [iQMediaGroup].[dbo].[IQAgent_SearchRequest].ID = Tmp.SRID
		where [iQMediaGroup].[dbo].[IQAgent_SearchRequest].IsActive = 1
		and [IQAgent_SearchRequest].ID not In (select distinct a.b.value('.[1]', 'int') as SRID 
					from [IQMediaGroup].[dbo].[IQNotificationSettings]
					cross apply [SearchRequestList].nodes('//SearchRequestID') as a(b)
					where Frequency = 'Immediate' and IsActive = 1)
		and ([Client].IQAgentGroup IS NULL OR [Client].IQAgentGroup != 'C')
		order by [IQAgent_SearchRequest].ID
END