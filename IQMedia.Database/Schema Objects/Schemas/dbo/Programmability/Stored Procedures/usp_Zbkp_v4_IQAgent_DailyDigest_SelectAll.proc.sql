CREATE PROCEDURE [dbo].[usp_v4_IQAgent_DailyDigest_SelectAll]
	@ClientGuid uniqueidentifier,
	@PageNumner	int,
	@PageSize	int,
	@TotalResults int output
AS
BEGIN
	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	declare @gmt decimal(18,2)
	Select
			@gmt=Client.gmt
	From
			Client
	Where
			ClientGUID = @ClientGuid

	SELECT 
			@TotalResults = COUNT(*)
	FROM 
			IQAgent_DailyDigest
				inner join Client
					on Client.ClientGUID = IQAgent_DailyDigest._ClientGuid
	WHERE
			_ClientGuid = @ClientGuid
			and Client.IsActive = 1
			and IQAgent_DailyDigest.IsActive = 1

	;With tempEmailDigest AS(
		SELECT
				ROW_NUMBER() OVER (ORDER BY IQAgent_DailyDigest.CreatedDate desc) as RowNum,
				IQAgent_DailyDigest.ID,
				IQAgent_DailyDigest.EmailAddress,
				dateadd(hour,@gmt, IQAgent_DailyDigest.TimeOfDay) as TimeOfDay,
				(SELECT ', ' + Query_Name FROM IQAgent_SearchRequest inner join IQAgent_DailyDigest.AgentXml.nodes('IQAgentList/IQAgent') as a(agents) on IQAgent_SearchRequest.ID = a.agents.value('.','bigint') and IQAgent_SearchRequest.IsActive > 0 and IQAgent_SearchRequest.ClientGUID = @ClientGuid for xml path('')) as IQAgentNames
		FROM 
				IQAgent_DailyDigest
					inner join Client
						on Client.ClientGUID = IQAgent_DailyDigest._ClientGuid
		WHERE
				_ClientGuid = @ClientGuid
				and Client.IsActive = 1
				and IQAgent_DailyDigest.IsActive = 1
	)

	SELECT 
			ID,
			EmailAddress,
			TimeOfDay,
			IQAgentNames
	FROM
			tempEmailDigest
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
END