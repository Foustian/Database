-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_SelectByClientGUID] 
	@CustomerGUID uniqueidentifier,
	@ClientGUID uniqueidentifier,
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
		
		INNER JOIN Customer
		On IQCustomer_SavedSearch.CustomerGUID = Customer.CustomerGUID
					
		INNER JOIN Client
		ON Customer.ClientID = Client.ClientKey
	
		Where
			IQCustomer_SavedSearch.IsActive = 1 AND Customer.IsActive = 1 AND Client.IsActive = 1
		AND
			Client.ClientGUID = @ClientGUID

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

	DECLARE @TempSavedSearch TABLE(RowOrder int,ID bigint,Title varchar(max),CustomerGuid uniqueidentifier,IsIQAgent bit)
	
	INSERT INTO @TempSavedSearch
	--SELECT *FROM
	SELECT
					1,
					IQCustomer_SavedSearch.ID,
					IQCustomer_SavedSearch.Title,
					IQCustomer_SavedSearch.CustomerGUID,
					IQCustomer_SavedSearch.IsIQAgent
			From
					IQCustomer_SavedSearch
					
					INNER JOIN Customer
					On IQCustomer_SavedSearch.CustomerGUID = Customer.CustomerGUID
					
					INNER JOIN CLIENT
					ON Customer.ClientID = Client.ClientKey
			Where
					IQCustomer_SavedSearch.IsActive = 1 AND Customer.IsActive = 1 AND Client.IsActive = 1
			AND
					Client.ClientGUID = @ClientGUID
					AND (@DefaultSavedSearchID IS NULL OR ID !=  @DefaultSavedSearchID )
					AND ((@ISCustomerAccess = 1 AND @ISClientAccess = 1) OR (IsIQAgent = 0 OR  IsIQAgent IS NULL))
					AND IQCustomer_SavedSearch.CustomerGUID = @CustomerGUID
			
			union 
			SELECT
					2,
					IQCustomer_SavedSearch.ID,
					IQCustomer_SavedSearch.Title,
					IQCustomer_SavedSearch.CustomerGUID,
					IQCustomer_SavedSearch.IsIQAgent
			From
					IQCustomer_SavedSearch
					
					INNER JOIN Customer
					On IQCustomer_SavedSearch.CustomerGUID = Customer.CustomerGUID
					
					INNER JOIN CLIENT
					ON Customer.ClientID = Client.ClientKey
			Where
					IQCustomer_SavedSearch.IsActive = 1 AND Customer.IsActive = 1 AND Client.IsActive = 1
			AND
					Client.ClientGUID = @ClientGUID
					AND (@DefaultSavedSearchID IS NULL OR ID !=  @DefaultSavedSearchID )
					AND ((@ISCustomerAccess = 1 AND @ISClientAccess = 1) OR (IsIQAgent = 0 OR  IsIQAgent IS NULL))
					AND IQCustomer_SavedSearch.CustomerGUID != @CustomerGUID

	;WITH TempIQCustomer_SavedSearch  
	AS (
			SELECT 
			ROW_NUMBER() OVER (ORDER BY RowOrder asc, Title asc)	as RowNumber,
			ID,
			Title,
			CustomerGuid,
			IsIQAgent
		FROM
			@TempSavedSearch

	)
	SELECT *FROM TempIQCustomer_SavedSearch Where RowNumber >=@StartRowNo AND RowNumber <= @EndRowNo 
			
END
