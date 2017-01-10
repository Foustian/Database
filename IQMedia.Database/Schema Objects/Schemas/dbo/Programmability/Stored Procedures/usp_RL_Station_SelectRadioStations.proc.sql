CREATE PROCEDURE [dbo].[usp_RL_Station_SelectRadioStations]

AS
BEGIN	
	SET NOCOUNT ON;

    Select
			IQ_Station.dma_name,
			IQ_Station.dma_num,
			IQ_Station.IQ_Station_ID,
			IQ_Station.gmt_adj,
			IQ_Station.dst_adj
	From
			IQ_Station
	Where
			IQ_Station.IsActive=1 and
			IQ_Station.Format='RADIO'
    
END
