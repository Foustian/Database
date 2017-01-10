CREATE PROCEDURE [dbo].[usp_v4_fliQ_ClientApplication_SelectAll]
	@ClientName varchar(155),
	@ApplicationName varchar(155),
	@PageNumner	int,
	@PageSize	int,
	@TotalResults int output
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StartRow int, @EndRow int

	SET @StartRow = (@PageNumner  * @PageSize) + 1
	SET @EndRow = (@PageNumner  * @PageSize) + @PageSize

	SELECT
			@TotalResults = COUNT(*)
	FROM
			fliQ_ClientApplication	
				inner join fliQ_Application
					on fliQ_ClientApplication._FliqApplicationID = fliQ_Application.ID
					and fliQ_Application.IsActive = 1
				inner  join Client
					on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
					and  Client.IsFliq = 1 and Client.IsActive = 1
	WHERE
			(@ClientName IS NULL OR Client.ClientName = @ClientName)
	
	;With tempClientApplication AS(
		SELECT
				ROW_NUMBER() OVER (ORDER BY  [Application] asc,ClientName asc) as RowNum,
				fliQ_ClientApplication.ID,
				fliQ_Application.[Application],
				fliQ_Application.[Description],
				fliQ_Application.[Path],
				Client.ClientName,
				fliQ_ClientApplication.FTPHost,
				fliQ_ClientApplication.FTPPath,
				fliQ_ClientApplication.FTPLoginID,
				fliQ_ClientApplication.FTPPwd,
				fliQ_ClientApplication.IsCategoryEnable,
				fliQ_ClientApplication.IsActive,
				fliQ_ClientApplication.ForceLandscape,
				fliQ_ClientApplication.MaxVideoDuration,
				CustomCategory.CategoryName
		FROM
				fliQ_ClientApplication	
					inner join fliQ_Application
						on fliQ_ClientApplication._FliqApplicationID = fliQ_Application.ID
							and fliQ_Application.IsActive = 1
					inner  join Client
						on fliQ_ClientApplication.ClientGUID = Client.ClientGUID
						and  Client.IsFliq = 1 and Client.IsActive = 1
					left outer join CustomCategory
						on fliQ_ClientApplication.DefaultCategory = CustomCategory.CategoryGUID
						and CustomCategory.IsActive = 1
		WHERE
				(@ClientName IS NULL OR Client.ClientName = @ClientName)
				and (@ApplicationName IS NULL OR fliQ_Application.[Application] like '%'+ @ApplicationName +'%' OR fliQ_Application.[Description] like '%'+ @ApplicationName +'%')
	)

	SELECT
			ID,
			[Application],
			[Description],
			[Path],
			ClientName,
			FTPHost,
			FTPPath,
			FTPLoginID,
			FTPPwd,
			IsActive,
			CategoryName,
			IsCategoryEnable,
			ForceLandscape,
			MaxVideoDuration
	FROM
			tempClientApplication
	WHERE
			RowNum >= @StartRow AND RowNum <= @EndRow
			


END