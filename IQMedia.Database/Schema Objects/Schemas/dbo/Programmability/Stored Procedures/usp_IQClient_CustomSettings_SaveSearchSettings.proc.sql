
CREATE PROCEDURE [dbo].[usp_IQClient_CustomSettings_SaveSearchSettings]	
(
	@ClientID		bigint,
	@SearchSettings	xml	
)
AS
BEGIN
	
	SET NOCOUNT OFF;
	DECLARE @RowAffected int
	DECLARE @ClientGuid uniqueidentifier
	SELECT @ClientGuid = ClientGuid FROM Client WHERE ClientKey=@ClientID 
	IF NOT EXISTS(SELECT 
						_ClientGuid
				  FROM 
						IQClient_CustomSettings
				  WHERE			
						_ClientGuid=@ClientGuid AND
						Field = 'SearchSettings'
						
				 )
	BEGIN
			INSERT INTO IQClient_CustomSettings(
					_ClientGuid,
					Field,
					Value)
				  VALUES(
					@ClientGuid,
					'SearchSettings',
					Convert(varchar(max),@SearchSettings));
					
			SET @RowAffected = @@ROWCOUNT
	END
	ELSE
	BEGIN
		UPDATE 
			IQClient_CustomSettings
		SET 
			Value = Convert(varchar(max),@SearchSettings)
		WHERE 
			_ClientGuid = @ClientGuid 
			AND Field ='SearchSettings'
			
		SET @RowAffected = @@ROWCOUNT
		
	END
	
	SELECT @RowAffected as RowAffected
	
	
END
