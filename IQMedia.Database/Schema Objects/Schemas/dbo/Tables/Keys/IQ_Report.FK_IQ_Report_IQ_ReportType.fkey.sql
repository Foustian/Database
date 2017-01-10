ALTER TABLE [dbo].[IQ_Report]  WITH CHECK ADD  CONSTRAINT [FK_IQ_Report_IQ_ReportType] FOREIGN KEY([_ReportTypeID])
REFERENCES [dbo].[IQ_ReportType] ([ID])
GO
ALTER TABLE [dbo].[IQ_Report] CHECK CONSTRAINT [FK_IQ_Report_IQ_ReportType]
GO
