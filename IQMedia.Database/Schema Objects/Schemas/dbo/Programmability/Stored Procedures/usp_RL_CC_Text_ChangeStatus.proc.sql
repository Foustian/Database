
CREATE PROCEDURE [dbo].[usp_RL_CC_Text_ChangeStatus]
(
	@StatusMsg		varchar(Max)='Core1' ,
	@IQ_CC_Keys		varchar(Max)
)
AS
BEGIN
	SET NOCOUNT OFF;
	
	declare @Query nvarchar(Max)
	
	set @Query='update
						RL_CC_Text
				set
						CC_File_Status='''+@StatusMsg+''',
						CC_Ingest_Date=GETDATE()
				 Where IQ_CC_Key in ('+@IQ_CC_Keys+')'
				
	--print @Query
				
	exec sp_executesql @Query


END
