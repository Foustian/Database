CREATE PROCEDURE [dbo].[usp_isvc_IQ_Station_SelectRadioStation]
AS
BEGIN	
	SET NOCOUNT ON;
	
	Select
			IQ_Station.dma_name,
			IQ_Station.dma_num,
			IQ_Station.IQ_Station_ID			
	From
			IQ_Station
	Where
			IQ_Station.IsActive=1 and
			IQ_Station.Format='RADIO'

    
END