-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_GetDataByID]
	@ID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    Select 
		IQCustomer_SavedSearch.* ,
		CASE WHEN IQCustomer_DefaultSettings.Value IS NULL THEN 0 ELSE 1 END as IsDefualtSearch
	From 
		IQCustomer_SavedSearch 
			LEFT OUTER JOIN IQCustomer_DefaultSettings 
				ON Convert(Varchar(10),IQCustomer_SavedSearch.ID) = Convert(Varchar(10),IQCustomer_DefaultSettings.Value)
				AND IQCustomer_SavedSearch.CustomerGuid = IQCustomer_DefaultSettings._CustomerGuid 
				AND Field ='IQPremium'
	Where
		 IsActive = 1
	AND
		 ID = @ID
    
END
