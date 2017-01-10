-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_SavedSearch_Select]
	@PageNumber			int,
	@PageSize			int,
	--@ID					int,
	@CustomerGUID	uniqueidentifier,
	@TotalRecords	int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1;
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize;
	
	Select @TotalRecords =  Count(*) From IQDiscovery_SavedSearch Where IsActive = 1 AND CustomerGuid = @CustomerGUID 
	
	
	Select * From
	(
	Select 
		Row_Number() over (ORDER BY Title) as RowNumber,
		ID,
		Title,
		SearchTerm,
		SearchID
		
	From
		IQDiscovery_SavedSearch
	WHERE 
		CustomerGuid = @CustomerGUID 
		AND IsActive = 1 
	--AND (@ID is null or ID <> @ID)
		)a
	Where RowNumber >=@StartRowNo AND RowNumber <= @EndRowNo 
	
END
