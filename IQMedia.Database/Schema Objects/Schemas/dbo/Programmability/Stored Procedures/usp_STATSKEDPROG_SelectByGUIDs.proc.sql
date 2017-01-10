-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- 
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByGUIDs] 
	-- Add the parameters for the stored procedure here
	@GUIDs			VARCHAR(MAX)
	
AS
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		
		DECLARE @Query NVARCHAR(MAX)
	 
		SET @Query = ' with IQ_master_key_tbl As (
	select ROW_NUMBER() OVER (PARTITION BY STATSKEDPROG.IQ_CC_KEY ORDER BY substring(IQ_Master_key,22,4)) as RowNumber,
	StatSkedProg.iq_master_key,
	RL_GUIDS.RL_GUID,
	Station_ID,IQ_Dma_Name,IQ_Dma_Num,IQ_Local_Air_Date,IQ_Local_Air_Time,Title120,STATSKEDPROG.IQ_CC_Key
	FROM 
		StatSkedProg INNER JOIN RL_GUIDS ON STATSKEDPROG.IQ_CC_Key = RL_GUIDS.IQ_CC_Key		
	WHERE
		RL_GUID IN ('+@GUIDs+')
) 	Select * from IQ_master_key_tbl
						 where IQ_master_key_tbl.RowNumber=1'
		
		EXEC SP_EXECUTESQL @Query
   
   END

