CREATE PROCEDURE [dbo].[usp_v4_CustomCategory_UpdateRankings]
	@CategoryRankingXml XML,
	@RowCount INT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE	CustomCategory
	SET		CategoryRanking = tbl.c.value('@ranking', 'int'),
			ModifiedDate = GETDATE()
	FROM	CustomCategory
	INNER	JOIN @CategoryRankingXml.nodes('list/item') AS tbl(c)
			ON tbl.c.value('@guid', 'uniqueidentifier') = CustomCategory.CategoryGUID

	SET @RowCount = @@ROWCOUNT

END