-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_Recordfile_UpdateStatus]
	@RecordGuid uniqueidentifier,
	@Status	varchar(50)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	UPDATE
		IQCore_Recordfile
	Set 
		Status = @Status
	Where
		Guid = @RecordGuid		
	
	Select @@RowCount
		  
END
