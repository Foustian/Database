-- =============================================
-- Author:		<Author,,Name>
-- Create date: 15 July 2013
-- Description:	Select radio stations
-- =============================================
CREATE PROCEDURE [dbo].[usp_v4_IQ_Station_SelectRadioStations]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 			
			DMA_Name as Market,
			IQ_Station_ID AS StationID
	FROM	IQ_Station
	WHERE	Format = 'RADIO'
	AND		IsActive = 1
	
END
