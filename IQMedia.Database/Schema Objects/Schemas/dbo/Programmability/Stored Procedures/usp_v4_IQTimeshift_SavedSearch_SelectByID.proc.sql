CREATE PROCEDURE [dbo].[usp_v4_IQTimeshift_SavedSearch_SelectByID]
	@ID bigint,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Select
		Title,
		SearchTerm,		
		ID
	From 
		IQTimeshift_SavedSearch
	Where ID = @ID
		And CustomerGuid = @CustomerGuid
	
END