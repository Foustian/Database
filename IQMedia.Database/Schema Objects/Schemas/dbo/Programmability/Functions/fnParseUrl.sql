CREATE FUNCTION [dbo].[fnParseURL] (@strURL varchar(2048))
RETURNS varchar(2048)
AS
BEGIN

IF (@strURL like 'about:blank%' OR
	@strURL like 'externalInterface%' OR
	@strURL like 'file://%' OR
	@strURL like 'mhtml:%' OR
	@strURL like 'outbind://%' OR
	@strURL like 'resource://%' OR
	@strURL like 'wlmailhtml:%' OR
	@strURL = 'IOS')
  BEGIN
	SELECT @strURL = null
  END
ELSE
  BEGIN
	SELECT @strURL = REPLACE(@strURL,'https://','')
	SELECT @strURL = REPLACE(@strURL,'http://','')
	SELECT @strURL = REPLACE(@strURL,'www.','')

	-- Remove everything after "/" if one exists
	IF CHARINDEX('/',@strURL) > 0 (SELECT @strURL = LEFT(@strURL,CHARINDEX('/',@strURL)-1))
  END

RETURN @strURL	
END