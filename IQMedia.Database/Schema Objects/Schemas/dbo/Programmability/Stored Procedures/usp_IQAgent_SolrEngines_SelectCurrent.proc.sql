CREATE PROCEDURE [dbo].[usp_IQAgent_SolrEngines_SelectCurrent]
AS

BEGIN
	SELECT [MediaType], [BaseUrl], [ShardsUrl] 
      FROM [IQMediaGroup].[dbo].[IQSolrEngines]
        WHERE [Requestor] = 'IQAgent' and [IsActive] = 1
          and SYSUTCDATETIME() between [FromDate] and [ToDate]
END