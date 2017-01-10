-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Schedular_SelectAll]
@date datetime
AS
BEGIN
	SET NOCOUNT ON;
	
	Select * from Schedular where cast(BeginTime as DATE) in (cast(dateadd(d,-1,@date) as date),cast(@date as date),cast(dateadd(d,1,@date) as date))
END

