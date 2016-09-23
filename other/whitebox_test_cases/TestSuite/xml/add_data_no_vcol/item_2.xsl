<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="DATA">#ItemSourceId,TrialUnitSpecimenId,ItemUnitId,ItemTypeId,Amount
<xsl:apply-templates select="ROW"/>
</xsl:template>

<xsl:template match="ROW">
  <xsl:value-of select="ItemSourceId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="TrialUnitSpecimenId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="UnitId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="ItemTypeId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="Amount/@Value"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
