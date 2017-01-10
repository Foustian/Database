CREATE FUNCTION [dbo].[fnFormatDaypartDateTime]
(
	@DayOfWeek smallint,
	@Hour smallint
)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @RetVal VARCHAR(50)

	SET @RetVal = 
		CASE @DayOfWeek
			WHEN -1 THEN 'Total'
			WHEN 1 THEN 'Sunday'
			WHEN 2 THEN 'Monday'
			WHEN 3 THEN 'Tuesday'
			WHEN 4 THEN 'Wednesday'
			WHEN 5 THEN 'Thursday'
			WHEN 6 THEN 'Friday'
			WHEN 7 THEN 'Saturday' 
		END + ' ' +
		CASE WHEN  @Hour = -1 THEN ''
			WHEN  @Hour = 0 THEN '12:00 AM'
			WHEN @Hour BETWEEN 1 AND 9 THEN '0' + CAST(@Hour AS VARCHAR(2)) + ':00 AM'
			WHEN @Hour BETWEEN 10 AND 11 THEN CAST(@Hour AS VARCHAR(2)) + ':00 AM'
			WHEN @Hour = 12 THEN '12:00 PM'
			WHEN @Hour BETWEEN 13 AND 21 THEN '0' + CAST(@Hour - 12 AS VARCHAR(2)) + ':00 PM'
			WHEN @Hour BETWEEN 22 AND 23 THEN CAST(@Hour - 12 AS VARCHAR(2)) + ':00 PM' 
		END

	RETURN @RetVal
END
