USE [cdb ]
GO

/****** Object:  Table [dbo].[tblContacts]    Script Date: 2/7/2016 1:53:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblContacts](
    [ContactId] [int] IDENTITY(1,1) NOT NULL,
    [CompanyId] [int] NULL,
    [FirstName] [nvarchar](50) NULL,
    [LastName] [nvarchar](50) NULL,
    [Email] [nvarchar](50) NULL,
    [Phone] [nvarchar](50) NULL,
    [PhoneName1] [nvarchar](50) NULL,
    [Phone1] [nvarchar](50) NULL,
    [PhoneName2] [nvarchar](50) NULL,
    [Phone2] [nvarchar](50) NULL,
    [OtherPhone] [nvarchar](50) NULL,
    [Fax] [nvarchar](50) NULL
) ON [PRIMARY]

GO
Now the Notes table