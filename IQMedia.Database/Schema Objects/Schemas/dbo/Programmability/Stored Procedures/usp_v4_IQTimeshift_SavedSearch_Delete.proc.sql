CREATE PROCEDURE [dbo].[usp_v4_IQTimeshift_SavedSearch_Delete]
	@ID bigint,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	Update
		IQTimeshift_SavedSearch
	Set
		IsActive = 0,
		ModifiedDate = GETDATE()
	Where 
		ID = @ID
		And CustomerGuid = @CustomerGuid
	
END