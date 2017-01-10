USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_pshell_IQ_SSP_Table_Update]    Script Date: 8/20/2015 11:56:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[usp_pshell_IQ_SSP_Table_Update]
(	@STATUS	VARCHAR(10) Output
	
)
AS
BEGIN

	SET NOCOUNT ON;
	
begin try
	begin transaction
	  			     Merge Into [DBO].[IQ_SSP] As Target
							Using IQ_SSP_Replicated AS Source
							 ON		Target.[IQ_SSP_ID] = Source.[IQ_SSP_ID]
							AND Target.[IQ_SSP_Region] = Source.[IQ_SSP_Region]
							When Matched THEN
							UPDATE
							SET [Database_Key]= source.Database_Key,
								[IQ_CC_Key]=source.IQ_CC_Key,
								[title120]=source.title120,
								[tf_host]=source.tf_host,
								[tf_cast1]=source.tf_cast1,
								[tf_cast2]=source.tf_cast2,
								[tf_cast3]=source.tf_cast3,
								[tf_cast4]=source.tf_cast4,
								[tf_cast5]=source.tf_cast5,
								[tf_cast6]=source.tf_cast6,
								[desc100]=source.desc100,
								[tf_description2]=source.tf_description2,
								[tf_description3]=source.tf_description3,
								[IQ_Dma_Num]=source.IQ_Dma_Num,
								[IQ_Dma_Name]=source.IQ_Dma_Name,
								[IQ_Class_Num]=source.IQ_Class_Num,
								[IQ_Class]=source.IQ_Class,
								[IQ_Start_Point] =source.IQ_Start_Point,
								[IQ_Cat_Num]=source.IQ_Cat_Num,
								[IQ_Cat] =source.IQ_Cat,
								[Station_Affil_Num]=source.Station_Affil_Num,
								[Station_Affil]=source.Station_Affil,
								[iq_part] =source.iq_part,
								[iq_segs] =source.iq_segs,
								[iq_start_minute] =source.iq_start_minute,
								[Region]=source.Region,
								[Country] =source.Country,
								[Language]=source.Language
							When Not Matched By Target Then
							INSERT
								([IQ_SSP_ID],[IQ_SSP_Region],[Database_Key],[IQ_CC_Key],	[title120],[tf_host],[tf_cast1],[tf_cast2],[tf_cast3],										[tf_cast4],[tf_cast5],[tf_cast6],[desc100],
								[tf_description2],[tf_description3],[IQ_Dma_Num],[IQ_Dma_Name],[IQ_Class_Num],[IQ_Class],[IQ_Start_Point],[IQ_Cat_Num],									[IQ_Cat],[Station_Affil_Num],
								[Station_Affil],[iq_part],[iq_segs],[iq_start_minute],[Region],[Country],[Language]) Values
								([IQ_SSP_ID],[IQ_SSP_Region],[Database_Key],[IQ_CC_Key],	[title120],[tf_host],[tf_cast1],[tf_cast2],[tf_cast3],										[tf_cast4],[tf_cast5],[tf_cast6],[desc100],
								[tf_description2],[tf_description3],[IQ_Dma_Num],[IQ_Dma_Name],[IQ_Class_Num],[IQ_Class],[IQ_Start_Point],[IQ_Cat_Num],									[IQ_Cat],[Station_Affil_Num],
								[Station_Affil],[iq_part],[iq_segs],[iq_start_minute],[Region],[Country],[Language])
								When Not Matched By Source Then delete   ;
    
	commit transaction
	--update statistics IQ_SSP with fullscan, index
	SET @STATUS='SUCCESS'
end try
begin catch
	rollback transaction
	SET @STATUS='FAILURE'	

	DECLARE @IQMediaGroupExceptionKey BIGINT,
			@ExceptionStackTrace VARCHAR(500),
			@ExceptionMessage VARCHAR(500),
			@CreatedBy	VARCHAR(50),
			@ModifiedBy	VARCHAR(50),
			@CreatedDate	DATETIME,
			@ModifiedDate	DATETIME,
			@IsActive	BIT
			
	
			SELECT 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
				@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_pshell_IQ_SSP_Table_Update',
				@ModifiedBy='usp_pshell_IQ_SSP_Table_Update',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
end catch
END








GO


