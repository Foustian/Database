-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_STATSKEDPROG_SelectAllWithRegion_old] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT
	    IQ_Dma_Name,
		IQ_Dma_Num,
		RegionID
			
	FROM
		SSP_IQ_Dma_Name
	WHERE
		IsActive= 1
	ORDER BY
		IQ_Dma_Num
		
	SELECT
		IQ_Class,
		IQ_Class_Num
	FROM
		SSP_IQ_Class
	WHERE
		IsActive= 1
	 ORDER BY
		IQ_Class_Num
		
	select 
		 Station_Affil,
		 Station_Affil_Num
	from 
		SSP_Station_Affil
	where 
		IsActive=1
	ORDER BY
		Station_Affil_Num

END
