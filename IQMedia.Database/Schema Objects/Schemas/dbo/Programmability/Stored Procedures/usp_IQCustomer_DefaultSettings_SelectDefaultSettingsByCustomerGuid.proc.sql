-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_DefaultSettings_SelectDefaultSettingsByCustomerGuid]
	@CustomerGuid uniqueidentifier
AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT 
		IQPremiumSearchRequest,
		IQCustomer_SavedSearch.ID,
		IQCustomer_SavedSearch.Title,
		IQCustomer_SavedSearch.IsIQAgent
	From
		IQCustomer_SavedSearch 
			INNER JOIN IQCustomer_DefaultSettings 	
	ON 
		IQCustomer_SavedSearch.CustomerGuid = IQCustomer_DefaultSettings._CustomerGuid AND 
		IQCustomer_DefaultSettings.Field ='IQPremium' AND
		IQCustomer_SavedSearch.ID = Convert(bigint,IQCustomer_DefaultSettings.Value)
	Where
		IQCustomer_SavedSearch.CustomerGuid = @CustomerGuid
	
	
END
