package mdpm.oscar;

import static org.junit.Assert.*;

import org.junit.Test;

public class DatatypeTest extends SqlParserTest {

  @Test
  public void parseCharacterDatatypes() {
    parse("char").datatype();
    parse("char(1)").datatype();
    parse("char(1 char)").datatype();
    parse("char(1 byte)").datatype();
    parse("char(1024 char)").datatype();
    parse("char(2000)");

    parse("nchar").datatype();
    parse("nchar(1)").datatype();
    parse("nchar(1024)").datatype();
    try { parse("nchar(1 byte)").datatype(); fail("no `byte`"); } catch (SqlParserException ex) {};
    
    parse("character(1)").datatype();
    parse("character(1024)").datatype();

    parse("national character(1)").datatype();
    parse("national character(1024)").datatype();

    parse("national char (1)").datatype();
    parse("national char (1024)").datatype();

    parse("character varying (1)").datatype();
    parse("character varying (2024)").datatype();
    
    parse("varchar2(1)").datatype();
    parse("varchar2(1 char)").datatype();
    parse("varchar2(1024 char)").datatype();
    parse("varchar2(4000 char)").datatype();
    
    parse("char varying (1)").datatype();
    parse("char varying (2024)").datatype();

    parse("nchar varying (1)").datatype();
    parse("nchar varying (2024)").datatype();

    parse("nvarchar2(1)").datatype();
    parse("nvarchar2(1024)").datatype();
    parse("nvarchar2(4000)").datatype();
    
    parse("national character varying (1)").datatype();
    parse("national character varying (2024)").datatype();

    parse("national char varying (1)").datatype();
    parse("national char varying (1024)").datatype();

    parse("varchar(1)").datatype();
    parse("varchar(1024)").datatype();
  }
  
  @Test
  public void parseNumberDatatype() {
    parse("number").datatype();
    parse("number(1)").datatype();
    parse("number(1,4)").datatype();
    parse("number(1,-4)").datatype();
    parse("numeric").datatype();
    parse("numeric(1)").datatype();
    parse("numeric(1,1)").datatype();
    parse("decimal").datatype();
    parse("decimal(1)").datatype();
    parse("decimal(1,1)").datatype();
    parse("dec").datatype();
    parse("dec(1)").datatype();
    parse("dec(1,1)").datatype();

    parse("float").datatype();
    parse("float(1)").datatype();

    parse("binary_float").datatype();
    parse("binary_double").datatype();
    
    parse("integer").datatype();
    parse("int").datatype();
    parse("smallint").datatype();
    
    parse("double").datatype();
    parse("double precision").datatype();
    
    parse("real").datatype();
  }

  @Test
  public void parseLongAndRawDatatype() {
    parse("long").datatype();
    parse("long raw").datatype();
    parse("raw(1)").datatype();
    parse("raw(1024)").datatype();
  }

  @Test
  public void parseDatetimeDatatype() {
    parse("date").datatype();
    
    parse("timestamp").datatype();
    parse("timestamp(0)").datatype();
    parse("timestamp(1)").datatype();
    parse("timestamp with time zone").datatype();
    parse("timestamp with local time zone").datatype();
    parse("timestamp(0) with time zone").datatype();
    parse("timestamp(1) with time zone").datatype();
    parse("timestamp(0) with local time zone").datatype();
    parse("timestamp(1) with local time zone").datatype();
    
    parse("interval year to month").datatype();
    parse("interval year(1) to month").datatype();
    
    parse("interval day to second").datatype();
    parse("interval day(1) to second").datatype();
    parse("interval day to second(0)").datatype();
    parse("interval day to second(1)").datatype();
    parse("interval day(1) to second(1)").datatype();

    //parse("interval year(0) to month");
    //parse("interval year(1024) to month");
    //parse("interval day(0) to second");
    //parse("interval day(1024) to second");
    //parse("interval day to second(1024)");
    //parse("interval day(0) to second(0)");
    //parse("interval day(1024) to second(1024)");
  }
  
  @Test
  public void parseLargeObjectDatatypes() {
    parse("blob").datatype();
    parse("clob").datatype();
    parse("nclob").datatype();
    parse("bfile").datatype();
  }
  
  @Test
  public void parseRowIdDatatypes() {
    parse("rowid").datatype();

    parse("urowid").datatype();
    parse("urowid(1)").datatype();
    parse("urowid(1024)").datatype();
  }
  
  @Test
  public void parseOracleSuppliedDatatype() {
    parse("SYS.AnyData").datatype();
    parse("SYS.AnyType").datatype();
    parse("SYS.AnyDataSet").datatype();
    
    parse("XMLType").datatype();
    parse("URIType").datatype();
    
    parse("SDO_Geometry").datatype();
    parse("SDO_Topo_Geometry").datatype();
    parse("SDO_GeoRaster").datatype();
    
    parse("ORDAudio").datatype();
    parse("ORDImage").datatype();
    parse("ORDVideo").datatype();
    parse("ORDDoc").datatype();
    parse("ORDDicom").datatype();
    
    parse("SI_StillImage").datatype();
    parse("SI_AverageColor").datatype();
    parse("SI_PositionalColor").datatype();
    parse("SI_ColorHistogram").datatype();
    parse("SI_Texture").datatype();
    parse("SI_FeatureList").datatype();
    parse("SI_Color").datatype();
  }

}