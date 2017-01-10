-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQRootpath_Location_SelectRemote_SvcUrlByRootPathID]
	@RootPathID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


		Select 
			Remote_SvcUrl
		From
			IQRootpath_Location
		Where
			_RootPathID = @RootPathID

END