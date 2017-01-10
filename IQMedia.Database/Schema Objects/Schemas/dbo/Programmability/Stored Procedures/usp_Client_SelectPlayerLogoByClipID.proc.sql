-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Client_SelectPlayerLogoByClipID] 
	@ClipID			uniqueidentifier
AS
BEGIN
	Declare @PlayerLogo varchar(MAX)
	Select 
		@PlayerLogo = PlayerLogo 
	from Client 
		inner join IQCore_ClipMeta 
			on IQCore_ClipMeta.Value = Client.ClientGUID 
			AND IQCore_ClipMeta.Field ='iqClientid'
		AND IQCore_ClipMeta._ClipGuid = @ClipID
		Where Client.IsActivePlayerLogo = 1
	select @PlayerLogo
END
