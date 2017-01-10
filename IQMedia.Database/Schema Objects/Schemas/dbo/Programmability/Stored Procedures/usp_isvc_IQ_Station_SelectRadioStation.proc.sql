CREATE PROCEDURE [dbo].[usp_isvc_IQ_Station_SelectRadioStation]

AS
BEGIN	
	SET NOCOUNT ON;
	
	SELECT
			IQ_Station.dma_name,
			IQ_Station.dma_num,
			IQ_Station.IQ_Station_ID			
	FROM
			IQ_Station
	WHERE
			IQ_Station.IsActive=1 AND
			IQ_Station.Format='RADIO'

    
END