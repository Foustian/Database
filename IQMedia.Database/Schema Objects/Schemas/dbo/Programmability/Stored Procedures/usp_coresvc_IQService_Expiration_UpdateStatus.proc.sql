-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQService_Expiration_UpdateStatus]
	@Status varchar(50),
	@RecordfileGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE [IQMediaGroup].[dbo].[IQService_Expiration]
    
	SET ExpirationStatus = @Status,
		ExpirationStatusDate = SYSDATETIME()
	
	Where RecordfileGuid = @RecordfileGuid
	and ExpirationStatus is Null
	
	Select @@RowCount
END
