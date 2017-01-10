
CREATE PROCEDURE [usp_Statskedprog_SelectPlayerDataForRawMedia]
(
	@RawMediaID		uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	
	Select
			IQ_Dma_Name,
			iq_local_air_date,
			Title120			
	From
			STATSKEDPROG
				inner join RL_GUIDS
					on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key
	Where
			RL_GUIDS.RL_GUID=@RawMediaID


END
