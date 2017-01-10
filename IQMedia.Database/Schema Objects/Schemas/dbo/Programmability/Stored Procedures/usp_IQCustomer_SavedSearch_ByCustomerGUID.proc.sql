-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_ByCustomerGUID]
	@CustomerGUID uniqueidentifier,
	@PageNumber			int,
	@PageSize			int,
	@DefaultSavedSearchID int, 
	@TotalRecords int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DEclare @ISCustomerAccess bit
	DEclare @ISClientAccess bit
	SELECT 
			@ISCustomerAccess = CustomerRole.IsAccess,
			@ISClientAccess = ClientRole.IsAccess
	FROM CustomerRole
			INNER JOIN Customer
				ON  CustomerRole.CustomerID =Customer.CustomerKey
			INNER JOIN ClientRole
				ON ClientRole.ClientID = Customer.ClientID
			INNER JOIN Role
				ON CustomerRole.RoleID = [Role].RoleKey
					AND ClientRole.RoleID =[Role].RoleKey
					AND ROleName ='iQPremiumAgent'					
					AND ClientRole.IsActive = 1 
					AND CustomerRole.IsActive = 1
					AND CustomerGuid  = @CustomerGUID


Select @TotalRecords = 
    COUNT(*)
	From
		IQCustomer_SavedSearch
	Where
			IsActive = 1
		AND
			CustomerGuid = @CustomerGUID

DECLARE @StartRowNo AS BIGINT,@EndRowNo AS BIGINT
	
	SET @StartRowNo = 1
	SET @EndRowNo = 1				
	
	SET @StartRowNo = (@PageNumber * @PageSize) + 1;
	SET @EndRowNo   = (@PageNumber * @PageSize) + @PageSize;
	
	if(@DefaultSavedSearchID IS NOT NULL)
	BEGIN
		SET @StartRowNo = @StartRowNo -@PageNumber;
	    SET @EndRowNo = @EndRowNo - @PageNumber - 1; 
		SET @TotalRecords = @TotalRecords +  CEILING(Convert(decimal,(@TotalRecords) / @PageSize));
	END

	;WITH TempIQCustomer_SavedSearch  
	AS (
			Select
					ROW_NUMBER() OVER (ORDER BY Title)  as RowNumber,
					ID,
					Title
			From
					IQCustomer_SavedSearch
			Where
					IsActive = 1
			AND
					CustomerGuid = @CustomerGUID 
					AND (@DefaultSavedSearchID IS NULL OR ID !=  @DefaultSavedSearchID )
					AND ((@ISCustomerAccess = 1 AND @ISClientAccess = 1) OR (IsIQAgent = 0 OR  IsIQAgent IS NULL))

	)
	SELECT *FROM TempIQCustomer_SavedSearch Where RowNumber >=@StartRowNo AND RowNumber <= @EndRowNo 
			
END
