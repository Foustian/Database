USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_DBJob_UpdateUniverse_IQ_Station]    Script Date: 3/16/2016 2:10:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[usp_DBJob_UpdateUniverse_IQ_Station] 
AS
BEGIN
	
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

BEGIN TRY 
  DECLARE @IQ_Station_ID varchar(255)
  DECLARE @UNIVERSE INT, @UM18_20 INT,@UM21_24 INT,@UM25_34 INT,@UM35_49 INT,@UM50_54 INT,@UM55_64 INT,@UM65 INT,
          @UF18_20 INT,@UF21_24 INT, @UF25_34 INT,@UF35_49 INT,@UF50_54 INT,@UF55_64 INT,@UF65 INT

  DECLARE t_cursor CURSOR FOR SELECT IQ_Station_ID FROM IQ_STATION WITH (NOLOCK)
  OPEN t_cursor
	  FETCH NEXT FROM t_cursor INTO @IQ_Station_ID
	  WHILE @@FETCH_STATUS = 0
		BEGIN
		   SELECT @UNIVERSE=0, @UM18_20=0,@UM21_24 =0,@UM25_34=0,@UM35_49=0,@UM50_54=0,@UM55_64=0,@UM65=0,
                  @UF18_20=0,@UF21_24=0,@UF25_34=04,@UF35_49=0,@UF50_54=0,@UF55_64=0,@UF65=0
		   SELECT @UNIVERSE= UNIVERSE, 
		   @UM18_20  = UM18_20,
		   @UM21_24  = UM21_24,
		   @UM25_34  = UM25_34,
		   @UM35_49  = UM35_49,
		   @UM50_54  = UM50_54,
		   @UM55_64  = UM55_64,
		   @UM65     = UM65,
           @UF18_20   = UF18_20,
		   @UF21_24   = UF21_24, 
		   @UF25_34   = UF25_34,
		   @UF35_49   = UF35_49,
		   @UF50_54   = UF50_54,
		   @UF55_64   = UF55_64,
		   @UF65      = UF65
		  FROM IQ_NIELSEN_SQAD WHERE ID = (SELECT MAX(ID) FROM IQ_NIELSEN_SQAD WITH (NOLOCK) WHERE SUBSTRING(IQ_CC_KEY,1,CHARINDEX('_',IQ_CC_KEY)-1) = @IQ_Station_ID)
		  PRINT CONVERT(varchar(30),@IQ_Station_ID)
		  UPDATE IQ_Station
		  SET   UNIVERSE= @UNIVERSE,
				UM18_20  = @UM18_20,
				UM21_24  = @UM21_24,
				UM25_34  = @UM25_34,
				UM35_49  = @UM35_49,
				UM50_54  = @UM50_54,
				UM55_64  = @UM55_64,
				UM65     = @UM65,
				UF18_20   = @UF18_20,
				UF21_24   = @UF21_24, 
				UF25_34   = @UF25_34,
				UF35_49   = @UF35_49,
				UF50_54   = @UF50_54,
				UF55_64   = @UF55_64,
				UF65      = @UF65
		   WHERE IQ_Station_ID = @IQ_Station_ID

		  FETCH NEXT FROM t_cursor INTO @IQ_Station_ID

		  
        END
	
        CLOSE t_cursor
	DEALLOCATE t_cursor
 
  RETURN 0

END TRY
BEGIN CATCH        
   
 
   DECLARE @IQMediaGroupExceptionKey BIGINT,
	   @ExceptionStackTrace VARCHAR(500),
	   @ExceptionMessage VARCHAR(500),
	   @CreatedBy	VARCHAR(50),
	   @ModifiedBy	VARCHAR(50),
	   @CreatedDate	DATETIME,
	   @ModifiedDate	DATETIME
	   -- @IsActive	BIT
	  SELECT 
		@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(VARCHAR(50),ERROR_LINE())),
		@ExceptionMessage=CONVERT(VARCHAR(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
		@CreatedBy='usp_DBJob_UpdateUniverse_IQ_Station',
		@ModifiedBy='usp_DBJob_UpdateUniverse_IQ_Station',
		@CreatedDate=GETDATE(),
		@ModifiedDate=GETDATE()
		--	@IsActive=1
				
        EXEC usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT

       CLOSE t_cursor
	DEALLOCATE t_cursor
	RETURN -1

END CATCH     
      
END
-- exec usp_DBJob_UpdateUniverse_IQ_Station



GO


