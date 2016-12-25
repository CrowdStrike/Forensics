<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/TR/WD-xsl">

 <xsl:template match="/">
  <xsl:for-each select="ROOT">
   <HTML>
    <HEAD><TITLE><xsl:value-of select="@CREATED_BY"/> Generated Log</TITLE></HEAD>
    <BODY>

     <CENTER><H1><xsl:value-of select="@CREATED_BY"/> Generated Log</H1></CENTER>
     <CENTER><H2>Generated on <xsl:value-of select="@DATE_CREATED"/></H2></CENTER>

     <CENTER>
      <TABLE BORDER="0" BGCOLOR="#E0E0E0" CELLPADDING="5">
       <xsl:apply-templates select="ROW"/>
      </TABLE>
     </CENTER>

    </BODY>
   </HTML>
  </xsl:for-each>
 </xsl:template> 

 <xsl:template match="ROW">
      <TR BGCOLOR="#F0F0F0">
	<xsl:for-each select="*">
	 <TD>
	  <xsl:value-of select="."/>
	 </TD>
	</xsl:for-each>
      </TR>
 </xsl:template> 
 
</xsl:stylesheet>