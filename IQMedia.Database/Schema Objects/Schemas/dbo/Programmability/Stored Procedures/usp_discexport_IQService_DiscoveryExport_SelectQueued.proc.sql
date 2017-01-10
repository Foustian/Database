CREATE PROCEDURE usp_discexport_IQService_DiscoveryExport_SelectQueued  
(  
  @TopRows INT,    
  @MachineName VARCHAR(255)    
)  
AS  
BEGIN  
  
 SET NOCOUNT ON;  
   
 ;WITH TempDiscExport AS    
  (    
  SELECT TOP(@TopRows)    
    ID  
  FROM    
    IQService_DiscoveryExport  
  WHERE     
    [Status] = 'QUEUED'    
  ORDER BY    
    ModifiedDate DESC  
  )    
    
 UPDATE     
  IQService_DiscoveryExport  
 SET    
  [Status] = 'SELECT',    
  MachineName = @MachineName,    
  ModifiedDate=GETDATE()    
 FROM     
  IQService_DiscoveryExport  
   INNER JOIN TempDiscExport  
    ON IQService_DiscoveryExport.ID = TempDiscExport.ID  
    AND IQService_DiscoveryExport.[Status] = 'QUEUED'    
    
  SELECT     
  ID,    
  SearchCriteria,  
  ArticleXml,  
  _RootPathID,  
  CreatedDate,  
  IsSelectAll      
  FROM    
  IQService_DiscoveryExport  
  WHERE    
  [Status] = 'SELECT'    
  AND MachineName = @MachineName    
  
END