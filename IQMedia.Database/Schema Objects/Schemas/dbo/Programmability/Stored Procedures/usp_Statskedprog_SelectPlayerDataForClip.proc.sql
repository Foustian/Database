
CREATE PROCEDURE [dbo].[usp_Statskedprog_SelectPlayerDataForClip]
(
	@ClipID		uniqueidentifier
)
AS
BEGIN

	SET NOCOUNT ON;
	
	Select
			IQ_Dma_Name,
			iq_local_air_date,
			Title120,
			STATSKEDPROG.Station_Id
	From
			STATSKEDPROG
				inner join RL_GUIDS
					on STATSKEDPROG.IQ_CC_Key=RL_GUIDS.IQ_CC_Key
				inner join IQCore_Clip
					on IQCore_Clip._RecordfileGuid=RL_GUIDS.RL_GUID
	Where
			IQCore_Clip.[Guid]=@ClipID


END
