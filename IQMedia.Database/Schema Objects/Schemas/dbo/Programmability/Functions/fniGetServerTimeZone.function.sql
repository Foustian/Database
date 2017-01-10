CREATE FUNCTION dbo.fniGetServerTimeZone(  )
RETURNS INT AS
BEGIN
    DECLARE    @viTZ INT
    SELECT @viTZ = ServerTimeZone FROM SYS_GetServerTimeZone
    RETURN @viTZ
END