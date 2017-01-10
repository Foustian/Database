-- =============================================
-- Author:		SAGAR JOSHI
-- Create date: 04/12/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[tmp_GetdataForIQCustom_byIQCCKey]
	@IqCCkey varchar(500)
AS
BEGIN
	
	SET NOCOUNT ON;
	



declare @sql varchar(max)

set @sql= ' select  IQ_CC_Key from STATSKEDPROG
where IQ_CC_Key  in (' + @IqCCkey + ')'

--select @sql
exec(@sql)
 

--declare @Delimiter varchar(1)
--set @Delimiter = ','
--declare @temptable TABLE (items varchar(8000)) 
--declare @idx bigint        
--declare @slice varchar(8000)        
       
--    select @idx = 1        
--        if len(@IqCCkey)<1 or @IqCCkey is null  return        
       
--    while @idx!= 0        
--    begin        
--        set @idx = charindex(@Delimiter,@IqCCkey)        
--        if @idx!=0       
--        begin 
      
--            set @slice = left(@IqCCkey,@idx - 1) 
            
--            end
--        else        
--            set @slice = @IqCCkey        
           
--        if(len(@slice)>0)   
--            insert into @temptable(Items) values(@slice)        
  
--        set @IqCCkey = right(@IqCCkey,len(@IqCCkey) - @idx)            
--        if len(@IqCCkey) = 0 break        
--    end  
   
--select distinct IQ_CC_Key from STATSKEDPROG
--where IQ_CC_Key in (select * from @temptable)

    
END
