-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQCustomer_SavedSearch_Delete]
	@ID varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;

   
    
    Declare @sql nvarchar(max)
    Set @sql = 'Update
		IQCustomer_SavedSearch
	Set
		IsActive = 0
	Where
		ID IN (' + @ID + ')
		
		Delete from IQCustomer_DefaultSettings Where Value IN ('  + @ID + ')
		
		Update IQAgent_SearchRequest
		Set IsActive = 0
		Where _CustomerSavedSearchID IN (' + @ID + ')'
		
		EXEC sp_executesql @sql
		
	
    
END
