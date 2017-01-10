CREATE PROCEDURE [dbo].[usp_v5_IQAgent_Analytics_TopTenData]
(
	@ClientGUID			uniqueidentifier,
	@Tab				varchar(50),
	@SearchRequestIDXml	xml
)	
AS
BEGIN
	
	IF @Tab = 'Networks'
		BEGIN
			SELECT Top 20 Station_Affil AS Category, SUM(Number_Hits) AS Total
			FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK)
			INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
				ON SearchRequestID = Search.req.value('@id', 'bigint')
			INNER JOIN IQMediaGroup.dbo.IQ_Station WITH (NOLOCK)
				ON Rl_Station = IQ_Station_ID
			WHERE GMTDatetime BETWEEN Search.req.value('@fromDate', 'date') AND Search.req.value('@toDate', 'date') AND IQAgent_TVResults.IsActive > 0
			GROUP BY Station_Affil
			ORDER BY Total DESC, Category ASC
		END
	IF @Tab = 'Shows'
		BEGIN
			SELECT Top 20 Title120 AS Category, SUM(Number_Hits) AS Total
			FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK)
			INNER JOIN @SearchRequestIDXml.nodes('list/item') as Search(req)
				ON SearchRequestID = Search.req.value('@id', 'bigint')
			WHERE GMTDatetime BETWEEN Search.req.value('@fromDate', 'date') AND Search.req.value('@toDate', 'date') AND IQAgent_TVResults.IsActive > 0
			GROUP BY Title120
			ORDER BY Total DESC, Category ASC
		END

END