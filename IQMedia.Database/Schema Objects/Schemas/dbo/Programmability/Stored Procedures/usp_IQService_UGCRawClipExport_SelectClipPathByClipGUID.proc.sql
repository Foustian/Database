-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQService_UGCRawClipExport_SelectClipPathByClipGUID]
	-- Add the parameters for the stored procedure here
	@ClipGUID	uniqueidentifier 
AS
BEGIN
	Select 
			IQService_UGCRawClipExport.OutputPath 	
	from 
			IQService_UGCRawClipExport
	where 
			ClipGUID = @ClipGUID
END
