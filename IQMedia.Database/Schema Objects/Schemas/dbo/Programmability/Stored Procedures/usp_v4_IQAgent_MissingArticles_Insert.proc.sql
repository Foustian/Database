CREATE PROCEDURE [dbo].[usp_v4_IQAgent_MissingArticles_Insert]  
 @ClientGuid uniqueidentifier,  
 @Title nvarchar(max),  
 @Content nvarchar(max),  
 @SearchRequestID bigint,  
 @Url varchar(255),  
 @Harvest_Time datetime,  
 @Category varchar(50),  
 @CustomerGuid uniqueidentifier,
 @AddToLibrary bit,  
 @LibraryCategory uniqueidentifier,  
 @MissingArticleID bigint output
AS  
BEGIN  
  
 Declare @IsValidSearchRequest bit  
  
 SELECT @IsValidSearchRequest = case when @Category ='NM' then IQAgent_SearchRequest.SearchTerm.exist('SearchRequest/News') else IQAgent_SearchRequest.SearchTerm.exist('SearchRequest/SocialMedia') end   
 From IQAgent_SearchRequest   
 where ID = @SearchRequestID And ClientGUID = @ClientGuid  
		AND ISActive=1
     
 if(@IsValidSearchRequest = 1)  
 BEGIN  
  if not EXists(Select IQAgent_MissingArticles.ID FROM IQAgent_MissingArticles INNER JOIN IQAgent_SearchRequest ON IQAgent_MissingArticles._SearchRequestID = IQAgent_SearchRequest.ID AND IQAgent_SearchRequest.ClientGUID = @ClientGuid Where _SearchRequestID= @SearchRequestID AND Url = @Url AND IQAgent_MissingArticles.IsActive = 1)  
  BEGIN  
   INSERT INTO IQAgent_MissingArticles  
   (  
    _SearchRequestID,  
    _CustomerGUID,  
    Title,  
    Content,  
    Url,  
    harvest_time,  
    Category,  
    Request_datetime,  
    Processed_flag,  
    CreatedDate,  
    ModifiedDate,
	AddToLibrary,
	IsActive,
	LibraryCategory
   )  
   SELECT  
    @SearchRequestID,  
    @CustomerGuid,  
    @Title,  
    @Content,  
    @Url,  
    @Harvest_Time,  
    @Category,  
    GETDATE(),  
    0,  
    GETDATE(),  
    GETDATE(),
	@AddToLibrary,
	1,
	@LibraryCategory
   FROM  
     IQAgent_SearchRequest   
      INNER JOIN Client   
       ON IQAgent_SearchRequest.ClientGUID = Client.ClientGUID  
       AND IQAgent_SearchRequest.ClientGUID = @ClientGuid   
      INNER JOIN Customer  
       ON Client.ClientKey = customer.ClientID  
       AND Customer.CustomerGUID = @CustomerGuid  
   WHERE  
     ID = @SearchRequestID   
    
  
   SET @MissingArticleID = SCOPE_IDENTITY()  
  END  
  Else  
  BEGIN  
   SET @MissingArticleID  = -1  
  END  
 END  
 ELSE  
 BEGIN  
  SET @MissingArticleID  = -2  
 END  
END