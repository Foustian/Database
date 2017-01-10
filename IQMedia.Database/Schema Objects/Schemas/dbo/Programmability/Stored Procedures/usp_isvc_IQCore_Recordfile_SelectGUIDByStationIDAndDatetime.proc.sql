-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_isvc_IQCore_Recordfile_SelectGUIDByStationIDAndDatetime]
(
	@Date DATETIME,
	@StationID VARCHAR(50),
	@IsDayLightSaving BIT,
	@IsGMTDateTime	BIT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF(@IsGMTDateTime=0)
	BEGIN
	
		DECLARE @dst INT
		DECLARE @gmt INT

		SELECT @dst = dst_adj,
			   @gmt = gmt_adj FROM IQ_Station WHERE IQ_Station_ID = @StationID
	
		IF(@IsDayLightSaving = 1)
		BEGIN		
			SELECT @Date = DATEADD(hh,@dst*(-1),@Date)
		END
		
		SELECT @Date = DATEADD(hh,@gmt*(-1),@Date)
	END
		
		SELECT 
			IQCore_RecordFile.[Guid]		
		FROM 
			IQCore_Recording WITH(NOLOCK)
		
			INNER JOIN IQCore_Source WITH(NOLOCK)
			ON IQCore_Recording._SourceGUID = IQCore_Source.[Guid]
			
			INNER JOIN IQCore_RecordFile WITH(NOLOCK)
			ON IQCore_Recording.ID = IQCore_RecordFile._RecordingID
			
			WHERE IQCore_Source.SourceID = @StationID 
			AND IQCore_Recording.StartDate = @Date
			AND IQCore_RecordFile._RecordfileTypeID IN ('2','9','10')
			AND IQCore_RecordFile.[Status] = 'READY' 
			AND IQCore_RecordFile._ParentGUID IS NULL
			AND IQCore_Source.IsActive =1
		
END
