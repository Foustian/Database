-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_OutboundReporting_Insert]   
 -- Add the parameters for the stored procedure here  
 @Query_Name varchar(150),  
 @FromEmailAddress varchar(150),  
 @ToEmailAddress varchar(150),  
 @MailContent xml,  
 @ServiceType varchar(150),  
 @OutboundReportingKey bigint output  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
  
   INSERT INTO   
	OutboundReporting  (  
			Query_Name,  
			FromEmailAddress,  
			ToEmailAddress,  
			MailContent,  
			ServiceType 
			)  
   VALUES  
	(  
    @Query_Name,  
    @FromEmailAddress,  
    @ToEmailAddress,  
    @MailContent,  
    @ServiceType  
   )  
     
   SELECT @OutboundReportingKey = SCOPE_IDENTITY()  
   Select @OutboundReportingKey
  
END  