-- =============================================
-- Create date: 20/Feb/2012
-- Description:	UPDATE CLIENT TABLE WITH CDNUpload value
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_UpdateCDNUploadByClientList]
	@xml xml,
	@IsEnable bit,
	@Status bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @tempxml xml
	set @tempxml = CAST(@xml as xml)
	Begin Transaction  
	BEGIN try
	update
         Client
	set
        CDNUpload=@IsEnable
	From
           Client
             inner join @tempxml.nodes('//Clients/ClientID') tbl(c) 
         on Client.ClientKey=tbl.c.query('.').value('.','bigint')
         Set @Status = 0;
         commit transaction  
         
	END TRY
	
	 begin catch  
		rollback transaction  
		set @Status =1;
	end catch     
	
		    
END
