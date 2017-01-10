
CREATE PROCEDURE usp_STATSKEDPROG_SelectByIQCCKeys
(
	@IQCCKeys		varchar(Max)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query NVARCHAR(MAX)
	 
		SET @Query = ' with IQ_master_key_tbl As 
					 (
						Select 
								ROW_NUMBER() OVER (PARTITION BY STATSKEDPROG.IQ_CC_KEY ORDER BY substring(IQ_Master_key,22,4)) as RowNumber,
								StatSkedProg.iq_master_key,	
								Title120,
								IQ_CC_Key
						FROM 
								StatSkedProg 
						WHERE
								IQ_CC_Key IN ('+@IQCCKeys+')
					) 	
					Select 
							* 
					From 
							IQ_master_key_tbl
					Where 
							IQ_master_key_tbl.RowNumber=1'
		
		EXEC SP_EXECUTESQL @Query


END
