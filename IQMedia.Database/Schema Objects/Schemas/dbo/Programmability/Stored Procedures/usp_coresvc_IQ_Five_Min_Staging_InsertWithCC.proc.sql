-- =============================================
-- Author:		Sagar Joshi
-- Create date: 03/May/2012
-- Description:	Insert IQ_Five_Min_Staging with cc
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_InsertWithCC]
	@IQ_CC_Key varchar(150)
	
		
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Return_Value bigint
	IF (NOT Exists(Select IQ_CC_Key from  IQ_Five_Min_Staging where IQ_CC_Key = @IQ_CC_Key))
	BEGIN
      
			INSERT into 
				IQMediaGroup.dbo.IQ_Five_Min_Staging
				 (
				  [IQ_CC_Key],
				  [CC_Process_Status],
				  [CreatedDate],
				  [ModifiedDate]
				  )
			Values 
				  (
				  @IQ_CC_Key,
				  'Initial',
				  SYSDATETIME(),
				  SYSDATETIME()
				  )
		Set @Return_Value = SCOPE_IDENTITY()
	END
		Else
	BEGIN         
         Set @Return_Value = -1
	END
	
	Select  @Return_Value


END
