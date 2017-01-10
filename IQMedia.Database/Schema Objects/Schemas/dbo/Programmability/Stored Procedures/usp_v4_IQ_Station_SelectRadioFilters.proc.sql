-- Create date: 15 July 2013
-- Description:	Select radio stations
-- =============================================
create PROCEDURE [dbo].[usp_v4_IQ_Station_SelectRadioFilters]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT 			
			DMA_Name as MarketName,
			Dma_Num AS MarketId
	FROM	IQ_Station
	WHERE	Format = 'RADIO'
	AND		IsActive = 1
	
	order by MarketName asc

		SELECT DISTINCT 			
			IQ_Station_ID as StationId,
			Station_Call_Sign AS StationName
	FROM	IQ_Station
	WHERE	Format = 'RADIO'
	AND		IsActive = 1
	
	order by StationName asc
END
