-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_coresvc_IQ_Five_Min_Staging_Insert]  
	@IQCCKey varchar(150)
AS
BEGIN
	SET NOCOUNT ON;
	Declare @InsertIdentity bigint
	Declare @TotalRec int
	Select @TotalRec =  COUNT(IQ_FiveMS_Key) from IQ_Five_Min_Staging where IQ_CC_Key = @IQCCKey 
	If(@TotalRec <= 0)
	begin
	
		INSERT into IQ_Five_Min_Staging(
			[IQ_CC_Key],
			[Media_Process_Status],
			[CreatedDate],
			[ModifiedDate]) 
		Values( 
			@IQCCKey,
			'Initial',
			SYSDATETIME(),
			SYSDATETIME())
			
			set @InsertIdentity = SCOPE_IDENTITY()
	end
	else
	begin
		set @InsertIdentity = -1
	end
select @InsertIdentity 
END
