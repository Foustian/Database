-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQ_NIELSEN_SQAD_SelectByIQ_CC_Keys]

@IQCCKeyList varchar(max)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select 
		 IQ_CC_KEY,AUDIENCE,SQAD_SHAREVALUE 
	FROM 
		IQ_NIELSEN_SQAD 
	WHERE
		IQ_CC_KEY IN (@IQCCKeyList)
    
END
