-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQDiscovery_SavedSearch_SelectByID]
	@ID bigint,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Select
		Title,
		SearchTerm,		
		AdvanceSearchSettings,
		AdvanceSearchSettingIDs,
		Medium,
		ID,
		SearchID
	From 
		IQDiscovery_SavedSearch
	Where ID = @ID
		And CustomerGuid = @CustomerGuid
	
END
