USE XQuery;
GO

--=============== Create XML schema ==================
CREATE XML SCHEMA COLLECTION top_xsd
AS
'<?xml version="1.0" encoding="utf-8"?>
<xs:schema id="top" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
  <xs:element name="top" msdata:IsDataSet="true" msdata:UseCurrentLocale="true">
    <xs:complexType>
      <xs:choice minOccurs="0" maxOccurs="unbounded">
        <xs:element name="mv">
          <xs:complexType>
            <xs:sequence>
              <xs:element name="Name" type="xs:string" minOccurs="0" msdata:Ordinal="0" />
              <xs:element name="Singer" type="xs:string" minOccurs="0" msdata:Ordinal="1" />
              <xs:element name="Views" type="xs:string" minOccurs="0" msdata:Ordinal="2" />
              <xs:element name="PublishedDate" type="xs:string" minOccurs="0" msdata:Ordinal="3" />
            </xs:sequence>
            <xs:attribute name="trackid" type="xs:string" />
          </xs:complexType>
        </xs:element>
      </xs:choice>
    </xs:complexType>
  </xs:element>
</xs:schema>';
GO

--=============== Create table containing XML element ==============
IF OBJECT_ID('dbo.check_DataExist') IS NOT NULL
	DROP FUNCTION dbo.check_DataExist;
GO
CREATE FUNCTION dbo.check_DataExist(@XML XML)
RETURNS BIT
AS
BEGIN
	RETURN @XML.exist('/top/mv');
END
GO

IF OBJECT_ID('dbo.TopMV') IS NOT NULL
	DROP TABLE dbo.TopMV;
GO
CREATE TABLE dbo.TopMV
(
	Xml_ID INT PRIMARY KEY IDENTITY(1, 1),
	Xml_MV XML(top_xsd) NOT NULL
	CONSTRAINT Xml_MV_Constraint CHECK(dbo.check_DataExist(Xml_MV) = 1)
)
GO

--=============== Create XML index ==================
CREATE PRIMARY XML INDEX xsd_ID ON dbo.TopMV(Xml_MV);
GO

CREATE XML INDEX xsd_IDX ON dbo.TopMV(Xml_MV)
USING XML INDEX xsd_ID FOR PATH
GO

--=============== Insert values =====================
INSERT INTO dbo.TopMV VALUES('
<top>
  <mv trackid="1">
    <Name>Perfect Strangers</Name>
    <Singer>Jonas Blue ft. JP Cooper</Singer>
    <Views>141960678</Views>
    <PublishedDate>2016-14-06</PublishedDate>
  </mv>
</top>
')

INSERT INTO dbo.TopMV VALUES('
<top>
  <mv trackid="4">
    <Name>Under you</Name>
    <Singer>Nick Jonas</Singer>
    <Views>7147362</Views>
    <PublishedDate>2016-28-06</PublishedDate>
  </mv>
</top>
')

INSERT INTO dbo.TopMV VALUES('
<top>
  <mv trackid="5">
    <Name>Bad Intentions</Name>
    <Singer>Niykee Heaton ft. Migos</Singer>
    <Views>1644392</Views>
    <PublishedDate>2016-15-06</PublishedDate>
  </mv>
</top>
')

INSERT INTO dbo.TopMV VALUES('
<top>
  <mv trackid="2">	
    <Name>Look alive</Name>
    <Singer>Rae Sremmurd</Singer>
    <Views>26748612</Views>
    <PublishedDate>2016-13-06</PublishedDate>
  </mv>
</top>
')

INSERT INTO dbo.TopMV VALUES('
<top>
  <mv trackid="3">
    <Name>Night Riders</Name>
    <Singer>Major Lazer ft. Travis Scott</Singer>
    <Views>11321201</Views>
    <PublishedDate>2016-14-06</PublishedDate>
  </mv>
</top>
')

SELECT * FROM dbo.TopMV;
GO

--=============== Method xml.exist() =================
DECLARE @XML XML
SET @XML = '<PublishedDate>2016-14-06</PublishedDate>'
SELECT @XML.exist('/PublishedDate') AS Exist
SELECT @XML.exist('/mv') AS Exist
GO

SELECT * FROM dbo.TopMV
WHERE Xml_MV.exist('/top/mv[@trackid="5"]') = 1
GO

--=============== Method xml.value() =================
SELECT Xml_ID,
	   Xml_MV.value('/top[1]/mv[1]/@trackid', 'NVARCHAR(10)') AS Track_ID,
	   Xml_MV.value('/top[1]/mv[1]/Name[1]', 'NVARCHAR(50)') AS Title,
	   Xml_MV.value('/top[1]/mv[1]/Singer[1]', 'NVARCHAR(50)') AS Singer
FROM dbo.TopMV
GO

SELECT Xml_MV.value('/top[1]/mv[1]/Name[1]', 'NVARCHAR(50)') AS [Title],
	   Xml_MV.value('/top[1]/mv[1]/PublishedDate[1]', 'NVARCHAR(20)') AS [PublishedDate],
	   Xml_MV.value('/top[1]/mv[1]/Views[1]', 'BIGINT') AS [Views]
FROM dbo.TopMV
ORDER BY [Views] DESC
GO

--=============== Method xml.query() =================
SELECT Xml_ID,
	   Xml_MV.query('/top[1]/mv[1]') AS [Information]
FROM dbo.TopMV
GO

-- #Using FLOWR statement
SELECT Xml_ID,
	   Xml_MV.query('for $name in /top[1]/mv[1]/Name[1]
					 return ($name)') AS [Name],
	   Xml_MV.query('for $name in /top[1]/mv[1]/Singer[1]
					 return ($name)') AS [Singer]			 
FROM dbo.TopMV
GO

-- #Using combination methods xml.exist(), xml.query()
SELECT Xml_ID,
	   Xml_MV.value('/top[1]/mv[1]/@trackid', 'NVARCHAR(10)') AS [Value_Track_ID],
	   Xml_MV.query('for $name in /top[1]/mv[1]/Name[1]
					 return ($name)') AS [Query_Name],
	   Xml_MV.query('for $name in /top[1]/mv[1]/Singer[1]
					 return ($name)') AS [Query_Singer]	 
FROM dbo.TopMV
WHERE Xml_MV.value('/top[1]/mv[1]/Views[1]', 'BIGINT') > 10000000
GO

--=============== Method xml.nodes() =================
DECLARE @xml XML
SET @xml = (SELECT TOP 1 Xml_MV 
			FROM dbo.TopMV 
			WHERE Xml_MV.value('/top[1]/mv[1]/Views[1]', 'BIGINT') > 10000000
			)
SELECT
    c.value('Name[1]', 'NVARCHAR(50)') AS [Title],
    c.value('Singer[1]', 'NVARCHAR(50)') AS [Singer],
    c.value('Views[1]', 'BIGINT') AS [Views],
    c.value('PublishedDate[1]', 'NVARCHAR(12)') AS [Published-Date]
FROM @xml.nodes('/top/mv') AS T(c)
GO

--=============== Method xml.modify(insert) =================
DECLARE @songs XML
SET @songs = '
<songs>
  <song ID="1">
    <details></details>
  </song>
</songs>'
SELECT @songs

SET @songs.modify(	-- Insert next
'insert <status>Official</status>
into (/songs/song/details)[1]')
SET @songs.modify(	-- Insert FIRST
'insert <title>Crush</title>
as first
into (/songs/song/details)[1]')
SET @songs.modify(	-- Insert LAST
'insert <singer>David Archuleta</singer>
as last
into (/songs/song/details)[1]')
SET @songs.modify(	-- Insert next
'insert <published-date>2011-09-20</published-date>
after (/songs/song/details/status)[1]')
SELECT @songs;
GO

--=============== Method xml.modify(delete) =================
DECLARE @songs XML = '
<songs>
  <song songID="1" singerID="7" theme="#">
    <details>
      <title>Crush</title>
      <status>Official</status>
      <published-date>2011-09-20</published-date>
      <singer>David Archuleta</singer>
    </details>  
  </song>
  <song songID="2" singerID="5" theme="#">
    <details>
      <title>Firestone</title>
      <status>Official</status>
      <published-date>2015-06-11</published-date>
      <singer>Kygo</singer>
      <extents>edited</extents>
    </details>  
  </song>
  <song songID="3" singerID="6" theme="#">
    <details>
      <title>Good times</title>
      <status>Official</status>
      <published-date>2013-07-07</published-date>
      <singer>Owl City ft. Carly Rae Jepsen</singer>
    </details>  
  </song>
</songs>'
SELECT @songs;

SET @songs.modify(	-- delete attribute
'delete /songs/song/@theme
')
SELECT @songs

SET @songs.modify(	-- delete element
'delete /songs/song[2]/details/extents
')
SELECT @songs

SET @songs.modify(	-- delete text node (in <status>)
'delete /songs/song[2]/details/status/text()
')
SELECT @songs

SET @songs.modify(	-- delete all processing instructions
'delete //processing-instruction()
')
SELECT @songs
GO

--=============== Method xml.modify(replace) =================
DECLARE @root XML
SET @root = '
<Root>
	<Location LocationID="10" LaborHours="1.1" MachineHours=".2">
		<details>Manufacturing steps are described here></details>
		<step>Manufacturing step 1 at this work center</step>
		<step>Manufacturing step 2 at this work center</step>
	</Location>
</Root>'
SELECT @root

-- update text in the first manufacturing step
SET @root.modify(
'replace value of (/Root/Location/step[1]/text())[1]
 with    "new text describing the menu step"
')
SELECT @root

-- update attribute value
SET @root.modify(
'replace value of (/Root/Location/@LaborHours)[1]
 with    "100.0"
')
SELECT @root
GO