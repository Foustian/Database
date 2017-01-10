CREATE PROCEDURE [dbo].[usp_iqsvc_IQClient_CustomSettings_CheckIQLicenseByCustomerID]
	@CustomerID bigint,
	@IQLicense tinyint
AS
BEGIN
		SELECT 
			ClientID
		from 		
			IQClient_CustomSettings cross apply Split(IQClient_CustomSettings.Value,',') as SplitTbl
				inner join Client 
					on IQClient_CustomSettings._ClientGuid = Client.ClientGUID
				inner join Customer 
					on Client.ClientKey = Customer.ClientID 
					and customer.CustomerKey = @CustomerID
		where					
			Client.IsActive = 1 
			and customer.IsActive = 1
			AND Field ='IQLicense' and CONVERT(tinyint,SplitTbl.Items) = @IQLicense	
END	
