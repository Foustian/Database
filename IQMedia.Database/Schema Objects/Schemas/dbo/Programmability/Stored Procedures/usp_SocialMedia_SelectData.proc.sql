-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SocialMedia_SelectData]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    
    Select
		Lable,
		Value
	From
		SM_SourceCategory
	Where
			IsActive = 1
	
	Order By
		Order_Number
		
		

   Select
		Lable,
		Value
	From
		SM_SourceType
	Where
			IsActive = 1
	
	Order By
		Order_Number
		
    
END
