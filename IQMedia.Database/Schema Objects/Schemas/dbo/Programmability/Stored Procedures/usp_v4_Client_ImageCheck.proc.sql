CREATE PROCEDURE [dbo].[usp_v4_Client_ImageCheck]
	@PlayerLogo varchar(max),
	@ClientKey bigint,
	@Status bit output
AS
BEGIN
	set @Status = 0
	if(@ClientKey IS NULL)
	begin
		IF Exists(Select ClientKey from Client where  PlayerLogo = @PlayerLogo)
		begin
			set @Status = 1
		end
	end
	else
	begin
		IF Exists(Select ClientKey from Client where  PlayerLogo = @PlayerLogo and ClientKey <> @ClientKey)
		begin
			set @Status = 1
		end
	end
END