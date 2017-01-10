USE [IQMediaGroup]
GO

/****** Object:  StoredProcedure [dbo].[usp_v5_Customer_ResetPasswordAttempts]    Script Date: 7/18/2016 7:02:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_v5_Customer_ResetPasswordAttempts]	
	@CustomerKey BIGINT
AS
BEGIN
	UPDATE IQMediaGroup.dbo.Customer
	SET PasswordAttempts = 0
	WHERE CustomerKey = @CustomerKey

	SELECT @@ROWCOUNT
END

GO

