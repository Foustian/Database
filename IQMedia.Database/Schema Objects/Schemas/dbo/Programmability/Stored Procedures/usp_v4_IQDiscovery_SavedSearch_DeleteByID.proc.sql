-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_SavedSearch_DeleteByID]
	@ID bigint,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Update
		IQDiscovery_SavedSearch
	Set
		IsActive = 0,
		DateModified = GETDATE()
	Where 
		ID = @ID
		And CustomerGuid = @CustomerGuid
	
END
