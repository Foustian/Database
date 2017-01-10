-- =============================================
-- Create date: 09/Feb/2012
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_ImageCheck]	
	@HeaderImage varchar(max),
	@PlayerLogo varchar(max),
	@ClientKey bigint,
	@Status bit output
AS
BEGIN
	
	
	SET NOCOUNT ON;
		
		set @Status = 0
	--Begin Transaction
	
	if(@ClientKey IS NULL)
		begin
				IF(Exists(Select *  from Client where
						(( CustomHeaderImage = @HeaderImage) or ( PlayerLogo = @HeaderImage) or ( CustomHeaderImage = @PlayerLogo) or ( PlayerLogo = @PlayerLogo))))

							begin
								set @Status = 1
							end
		end
	else
		begin
				IF(Exists(Select *  from Client where
						(( CustomHeaderImage = @HeaderImage) or ( PlayerLogo = @HeaderImage) or ( CustomHeaderImage = @PlayerLogo) or ( PlayerLogo = @PlayerLogo)) 
							and ClientKey <> @ClientKey))
							begin
								set @Status = 1
							end
		end
	--Commit Transaction
	-- return @Status 
    
END
