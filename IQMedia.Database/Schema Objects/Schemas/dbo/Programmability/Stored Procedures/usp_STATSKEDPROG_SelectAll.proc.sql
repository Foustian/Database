-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectAll] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT DISTINCT
			DMA_NAME,
			DMA_Num
	FROM 
			IQ_Station
	WHERE 
			IsActive= 1 AND
			Format ='TV'
	ORDER BY 
			DMA_Num
		
	SELECT
		IQ_Class,
		IQ_Class_Num
	FROM
		SSP_IQ_Class
	WHERE
		IsActive= 1
	 ORDER BY
		IQ_Class_Num
		
	select DISTINCT
		 Station_Affil,
		 Station_Affil_Num
	from 
		IQ_Station
	where 
		IsActive=1 AND
		Format ='TV'

	ORDER BY
		Station_Affil_Num
END
