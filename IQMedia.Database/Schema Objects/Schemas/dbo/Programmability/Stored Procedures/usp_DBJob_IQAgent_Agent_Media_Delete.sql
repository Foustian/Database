USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_IQAgent_Agent_Media_Delete]    Script Date: 10/20/2016 3:00:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[usp_DBJob_IQAgent_Agent_Media_Delete]
@NumberOfRecord INT, @DeleteStatus char(15) output
AS
BEGIN
   
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

-- Created Date :	August 2015
-- Description   :   

BEGIN TRY  	
Declare @AgentID bigint=NULL
Declare @Loop smallint = 1
select top 1 @AgentID =searchRequestID from IQAgent_DeleteControl WITH (NOLOCK) where searchRequestID is not NULL and isDBUpdated='TEMP' order by CreatedDate

IF (@AgentID IS NOT NULL) 
  BEGIN
     SET ROWCOUNT @NumberOfRecord
     WHILE @Loop = 1
	   BEGIN
			 BEGIN TRANSACTION
			   UPDATE IQAgent_MediaResults_Archive_2013
				   SET IsActive = 0
				   WHERE _SearchRequestID =  @AgentID   and Isactive=1   

				 UPDATE IQAgent_MediaResults_Archive_2014
				   SET IsActive = 0
				   WHERE _SearchRequestID =  @AgentID  and Isactive=1 

				   UPDATE IQAgent_MediaResults_Archive_2015
				   SET IsActive = 0
				   WHERE _SearchRequestID =  @AgentID  and Isactive=1 

				     UPDATE IQAgent_MediaResults_Archive_2016
				   SET IsActive = 0
				   WHERE _SearchRequestID =  @AgentID  and Isactive=1 

			   UPDATE IQAgent_MediaResults
				   SET IsActive = 0
				   WHERE _SearchRequestID =  @AgentID  and Isactive=1    
		   
			 Commit Transaction

		
		     IF EXISTS (SELECT * FROM IQAgent_MediaResults_Archive_2013 WITH (NOLOCK) WHERE _SearchRequestID =  @AgentID   and Isactive=1)
				  CONTINUE
			 ELSE
			    IF EXISTS (SELECT * FROM IQAgent_MediaResults_Archive_2014 WITH (NOLOCK) WHERE _SearchRequestID =  @AgentID   and Isactive=1)
		  			 CONTINUE
				ELSE 
				  IF EXISTS (SELECT * FROM IQAgent_MediaResults_Archive_2015 WITH (NOLOCK) WHERE _SearchRequestID =  @AgentID   and Isactive=1)
						CONTINUE
				  ELSE
				     IF EXISTS (SELECT * FROM IQAgent_MediaResults_Archive_2016 WITH (NOLOCK) WHERE _SearchRequestID =  @AgentID   and Isactive=1)
						CONTINUE
					 ELSE
						IF EXISTS (SELECT * FROM IQAgent_MediaResults WITH (NOLOCK) WHERE _SearchRequestID =  @AgentID   and Isactive=1)
							CONTINUE
						ELSE
							BEGIN
							   UPDATE IQAgent_DeleteControl 
							   SET isDBUpdated='COMPLETED', dbUpdateDate=getdate(), isSolrUpdated='QUEUED'
							   WHERE searchRequestID= @AgentID
							   BREAK
							END
	   END
		
	   set @DeleteStatus = 'DELETE SUCCEED'					
     
  END
ELSE
  IF (@AgentID IS NULL)
     set @DeleteStatus = 'DELETE IDLE'
 Return 0
END TRY
		BEGIN CATCH
		    Rollback Transaction
			set @DeleteStatus = 'DELETE FAIL'
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
				@CreatedBy='usp_v4_IQAgent_Agent_Media_Delete',
				@ModifiedBy='usp_v4_IQAgent_Agent_Media_Delete',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1
	

				EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT    
				Return -1
		END CATCH        

END





























GO


