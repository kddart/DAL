<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="DATA">#TrialUnitId,KeywordId
<xsl:apply-templates select="ROW"/>
</xsl:template>

<xsl:template match="ROW">
  <xsl:value-of select="TrialUnitId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="KeywordId/@Value"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
