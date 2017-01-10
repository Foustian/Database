CREATE FUNCTION [dbo].[fnGetClipAdjustedDateTime]
(
	@ClipDate			DATETIME,
	@GMT_Adjustment		FLOAT,
	@DST_Adjustment		FLOAT,
	@StartOffset		INT
	
)
RETURNS DATETIME
AS
BEGIN

	SET @ClipDate = DATEADD(HOUR,@GMT_Adjustment,@ClipDate)
	
	IF [dbo].[fnIsDayLightSaving](@ClipDate) = 1
		BEGIN
			SET @ClipDate = DATEADD(HOUR,@DST_Adjustment,@ClipDate)
		END
	
	--SET @ClipDate = DATEADD(SECOND,@StartOffset,@ClipDate)
	
	RETURN @ClipDate
	
END