USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_pshell_IQAgent_QHLRResults_Insert_sub_process]    Script Date: 3/16/2016 2:16:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[usp_pshell_IQAgent_QHLRResults_Insert_sub_process]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
BEGIN TRY 

	

	UPDATE #IQAgent_LRResults 
	  SET Hits=B.Hits, 
	      Hit_Count=B.Hit_Count
	  FROM #IQAgent_LRResults A, #IQAgent_LRResults_1 B
	        WHERE A.IQ_CC_KEY = B.IQ_CC_KEY 
		      AND  A._SearchLogoID = B._SearchLogoID 
			  AND  A.StartingPoint = B.StartingPoint

		RETURN 0
END TRY
BEGIN CATCH  
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
				@CreatedBy='usp_pshell_IQAgent_LRResults_Insert',
				@ModifiedBy='usp_pshell_IQAgent_LRResults_Insert',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE()
			--	@IsActive=1
				
        EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
		RETURN -1
END CATCH
END


GO


