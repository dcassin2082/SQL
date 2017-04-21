USE [cdb ]
GO

/****** Object:  Table [dbo].[tblNotes]    Script Date: 2/7/2016 1:52:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblNotes](
    [NoteId] [int] IDENTITY(1,1) NOT NULL,
    [Created] [date] NOT NULL,
    [ParentType] [nvarchar](50) NULL,
    [ParentId] [int] NOT NULL,
    [Creator] [nvarchar](50) NULL,
    [Notes] [nvarchar](max) NULL,
    [Private] [int] NULL,
    [Shared] [int] NULL,
    [Access] [nvarchar](50) NULL,
    [Sticky] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO