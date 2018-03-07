CREATE TABLE [dbo].[Songs] (
    [SongID]            INT        NOT NULL,
    [SongTitle]         NCHAR (50) NOT NULL,
    [SongSinger]        NCHAR (50) NOT NULL,
    [SongViewers]       BIGINT     NOT NULL,
    PRIMARY KEY CLUSTERED ([SongID] ASC)
);

