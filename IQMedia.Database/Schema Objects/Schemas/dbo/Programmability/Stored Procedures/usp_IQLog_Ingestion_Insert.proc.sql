-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQLog_Ingestion_Insert] 
	@StationID	varchar(20),
	@IQ_CC_Key	varchar(20),
	@MediaType	varchar(10),
	@date	datetime,
	@Level	varchar(20),
	@Logger	varchar(250),
	@LogMessage	varchar(4000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT OFF;
	
	DECLARE @Return_Value bigint
	
	INSERT INTO 
		IQLog_Ingestion
	VALUES
		(
			@StationID,
			@IQ_CC_Key,
			@MediaType,
			@date,
			@Level,
			@Logger,
			@LogMessage		
		)
		Set @Return_Value = SCOPE_IDENTITY()
		
		Select @Return_Value


END
