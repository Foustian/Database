CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_SelectAll]
	@ClientName varchar(500),
	@SearchTerm varchar(500),
	@PageNumner int,
	@PageSize int,
	@TotalResults bigint output
AS
BEGIN
	DECLARE @StartRow int, @EndRow int
	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

		SELECT
				
				@TotalResults = COUNT(*)
		FROM	
				IQClient_UGCMap	
					inner join IQCore_Source
						on 	IQClient_UGCMap.SourceGUID = IQCore_Source.[Guid]
						and IQCore_Source.IsActive = 1
					inner join Client
						on IQClient_UGCMap.ClientGUID = Client.ClientGUID
						and Client.IsActive = 1		
						and (@ClientName is null or Client.ClientName like '%' + @ClientName + '%')
						and (@SearchTerm is null or (IQCore_Source.Title like '%' + @SearchTerm + '%' or IQCore_Source.SourceID like '%' + @SearchTerm + '%' ))

	;With tempUGCMap AS(
		SELECT
				
				ROW_NUMBER() OVER (ORDER BY IQCore_Source.SourceID asc) as RowNun,
				IQClient_UGCMap.AutoClip_Status,
				IQClient_UGCMap.IQClient_UGCMapKey,
				IQCore_Source.SourceID,
				IQCore_Source.Title,
				IQCore_Source.BroadcastLocation,
				IQCore_Source.BroadcastType,
				Client.ClientName,
				IQClient_UGCMap.IsActive
		FROM	
				IQClient_UGCMap	
					inner join IQCore_Source
						on 	IQClient_UGCMap.SourceGUID = IQCore_Source.[Guid]
						and IQCore_Source.IsActive = 1
					inner join Client
						on IQClient_UGCMap.ClientGUID = Client.ClientGUID
						and Client.IsActive = 1		
						and (@ClientName is null or Client.ClientName like '%' + @ClientName + '%')
						and (@SearchTerm is null or (IQCore_Source.Title like '%' + @SearchTerm + '%' or IQCore_Source.SourceID like '%' + @SearchTerm + '%' ))
	)

	SELECT 
		AutoClip_Status,
		IQClient_UGCMapKey,
		SourceID,
		Title,
		BroadcastLocation,
		BroadcastType,
		ClientName,
		IsActive
	FROM
		tempUGCMap
	WHERE RowNun >= @StartRow and RowNun <= @EndRow
END