CREATE PROCEDURE usp_isvc_IQAgent_TVResults_SelectBySearchRequestID   
(  
	@ClientGuid   UNIQUEIDENTIFIER,  
	@CustomerGuid  UNIQUEIDENTIFIER,  
	@SearchRequestID BIGINT=NULL,  
	@SeqID    BIGINT=NULL,  
	@PageSize   INT   
)  
AS  
BEGIN   
	SET NOCOUNT ON;  
   
	DECLARE @IsNielsenAccess BIT, @TotalResults BIGINT, @MaxSinceID BIGINT  
  
	SET @SeqID = CASE WHEN @SeqID IS NULL THEN 0 ELSE @SeqID END  
  
	SELECT   
			@IsNielsenAccess = CASE WHEN  ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN 1 ELSE 0 END  
	FROM   
			[ROLE]  
				INNER JOIN CustomerRole   
					ON	CustomerRole.RoleID = [ROLE].RoleKey  
				INNER JOIN ClientRole  
					ON	ClientRole.RoleID = [ROLE].RoleKey  
					AND	CustomerRole.RoleID =ClientRole.RoleID   
				INNER JOIN Customer
					ON	Customer.CustomerKey = CustomerRole.CustomerID   
				INNER JOIN Client 
					ON  Client.ClientKey = ClientRole.ClientID  
					AND	Customer.ClientID = Client.ClientKey  
	WHERE  
			Customer.CustomerGUID   = @CustomerGUID     
		AND Client.ClientGUID = @ClientGUID  
		AND [ROLE].IsActive = 1 AND ClientRole.IsActive = 1 AND CustomerRole.IsActive = 1    
		AND Customer.IsActive =1 AND Client.IsActive = 1  
		AND RoleName ='NielsenData'  
    
	IF(@SearchRequestID IS NULL)  
	BEGIN  
			EXEC usp_isvc_IQAgent_TVResults_SelectWithoutSearchRequestID @ClientGUID,@SeqID,@PageSize,@IsNielsenAccess  
	END  
	ELSE  
	BEGIN  
			EXEC usp_isvc_IQAgent_TVResults_SelectWithSearchRequestID @ClientGUID,@SearchRequestID,@SeqID,@PageSize,@IsNielsenAccess  
	END    
END  