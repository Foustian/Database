CREATE PROCEDURE [dbo].[usp_v4_fliQ_Application_SelectAll]
	@Application varchar(155),
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
			fliQ_Application 
	WHERE
		(@Application IS NULL OR [Application] like '%'+@Application+'%')

	;WITH tempApplication AS(

		SELECT
				ROW_NUMBER() OVER (ORDER BY [Application] Asc) as RowNum,
				ID,
				[Application],
				[Version],
				[Path],
				[Description],
				IsActive,
				DateCreated,
				DateModified
		FROM	
				fliQ_Application
		WHERE
				(@Application IS NULL OR [Application] like '%'+@Application+'%')
	)

	SELECT 
			ID,
			[Application],
			[Version],
			[Path],
			[Description],
			IsActive,
			DateCreated,
			DateModified
	FROM 
			tempApplication 
	Where 
			RowNum >= @StartRow AND RowNum <= @EndRow
	
END