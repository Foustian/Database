USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQTimeshift_SavedSearch_Select]    Script Date: 12/9/2016 1:13:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQTimeshift_SavedSearch_Select]
	@PageNumber			int,
	@PageSize			int,
	@CustomerGuid	uniqueidentifier,
	@ComponentType  varchar(5),
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
	
	Select @TotalRecords =  Count(*) From IQTimeshift_SavedSearch Where IsActive = 1 AND CustomerGuid = @CustomerGuid and Component=@ComponentType
	
	
	;WITH tempIQTimeshift_SavedSearch AS(
		SELECT 
				Row_Number() over (ORDER BY Title) as RowNumber,
				ID,
				Title,
				SearchTerm
		From
				IQTimeshift_SavedSearch
		WHERE 
				CustomerGuid = @CustomerGuid 
				AND IsActive = 1
				AND Component=@ComponentType
	)
	SELECT ID,Title,SearchTerm FROM tempIQTimeshift_SavedSearch Where RowNumber >=@StartRowNo AND RowNumber <= @EndRowNo 
	
END
