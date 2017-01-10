CREATE procedure [dbo].[usp_v4_IQ_FacebookProfile_Select]
AS
BEGIN
	-- Used for ID-Name mapping, so include deleted
	SELECT ID,
		   FBPageID,
		   FBPageName,
		   FBLikes,
		   FBLink,
		   FBCategory,
		   FBIsVerified,
		   FBPicture
	  FROM IQMediaGroup.dbo.IQ_FBProfile
END

