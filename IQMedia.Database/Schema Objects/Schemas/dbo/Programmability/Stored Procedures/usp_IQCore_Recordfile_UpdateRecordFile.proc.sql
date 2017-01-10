-- =============================================  
-- Author:  DHARMESH SOLANKI  
-- Create date: 07 December 2011  
-- Description: This will Update Start Offset & End Offset for RecordFile  
-- =============================================  
  
  
CREATE PROCEDURE [dbo].[usp_IQCore_Recordfile_UpdateRecordFile]  
 @RecordfileID   UNIQUEIDENTIFIER,  
 @Location    VARCHAR(250),  
 @EndOffset    INT,  
 @RootPathID    INT ,
 @Status		VARCHAR(150) 
AS  
BEGIN  
  
 BEGIN TRY  
   
   BEGIN TRAN  
   Declare @RowAffected  int
   -- SET NOCOUNT ON added to prevent extra result sets from  
   -- interfering with SELECT statements.  
   SET NOCOUNT ON;  
  
    UPDATE IQCore_Recordfile   
    SET   
      Location = @Location,  
      EndOffset = @EndOffset,  
      _RootPathID = @RootPathID,
      [Status] = @Status,
      LastModified = SYSDATETIME()  
    WHERE [Guid] = @RecordfileID  
    
    Set @RowAffected  = @@ROWCOUNT
    
   COMMIT TRAN  

 END TRY  
   
 BEGIN CATCH  
    
  IF @@TRANCOUNT > 0  
   BEGIN  
    ROLLBACK TRAN  
    set @RowAffected =0;
   END  
 END CATCH  
 select @RowAffected
 
      
END  