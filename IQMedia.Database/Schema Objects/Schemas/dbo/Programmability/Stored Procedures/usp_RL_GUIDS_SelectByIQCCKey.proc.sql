
CREATE PROCEDURE [dbo].[usp_RL_GUIDS_SelectByIQCCKey]
(
	@IQ_CC_Key	 Varchar(Max)
)
AS
BEGIN	
	SET NOCOUNT ON;

declare @Query nvarchar(Max)

if(@IQ_CC_Key is not null and @IQ_CC_Key != '')
	begin		
	
			Set @Query='Select RL_GUIDS.RL_GUID,RL_GUIDS.IQ_CC_Key,RL_GUIDS.RL_Station_ID,RL_Station_Date,RL_Station_Time From RL_GUIDS Where RL_GUIDS.IQ_CC_Key in ('+@IQ_CC_Key+') and RL_GUIDS.IsActive=1'
	end
else
	begin	
	
			Set @Query='Select RL_GUIDS.RL_GUID,RL_GUIDS.IQ_CC_Key,RL_GUIDS.RL_Station_ID,RL_Station_Date,RL_Station_Time From RL_GUIDS Where RL_GUIDS.IQ_CC_Key in ('''') and RL_GUIDS.IsActive=1'
	
	end	

exec sp_executesql @Query
    
END
