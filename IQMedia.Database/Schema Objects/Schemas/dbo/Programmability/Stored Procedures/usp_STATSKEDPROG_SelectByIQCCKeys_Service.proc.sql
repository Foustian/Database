-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

-- 
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectByIQCCKeys_Service] 
	-- Add the parameters for the stored procedure here
	@IQCCKeys			VARCHAR(MAX)
	
AS
BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;
		
		DECLARE @Query NVARCHAR(MAX)
	 
		SET @Query = ' with IQ_master_key_tbl As (
						select 
								ROW_NUMBER() OVER (PARTITION BY STATSKEDPROG.IQ_CC_KEY ORDER BY substring(IQ_Master_key,22,4)) as RowNumber,						
								STATSKEDPROG.IQ_CC_Key,
								Title120
						FROM 
								StatSkedProg 
						WHERE
								IQ_CC_Key IN ('+@IQCCKeys+')
					) 	Select * from IQ_master_key_tbl
											 where IQ_master_key_tbl.RowNumber=1'
		
		EXEC SP_EXECUTESQL @Query
   
   END

