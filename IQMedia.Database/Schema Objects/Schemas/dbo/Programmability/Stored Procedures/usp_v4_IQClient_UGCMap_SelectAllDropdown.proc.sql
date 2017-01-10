USE [IQMediaGroup]
GO
/****** Object:  StoredProcedure [dbo].[usp_v4_IQClient_UGCMap_SelectAllDropdown]    Script Date: 11/2/2016 4:19:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v4_IQClient_UGCMap_SelectAllDropdown]
AS
BEGIN
	SELECT 
		ClientName,
		ClientGUID
	FROM 
		Client
	WHERE
		Client.IsActive = 1
			ORDER BY
		ClientName asc
	SELECT
		ID,
		Code,
		Name
	FROM
		IQMediaGroup.dbo.IQCore_Timezone
END