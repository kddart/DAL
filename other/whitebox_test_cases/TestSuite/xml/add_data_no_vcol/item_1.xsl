<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="DATA">#ItemSourceId,SpecimenId,ItemUnitId,ItemTypeId,Amount,ItemStateId,ItemBarcode,ItemNote
<xsl:apply-templates select="ROW"/>
</xsl:template>

<xsl:template match="ROW">
  <xsl:value-of select="ItemSourceId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="SpecimenId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="UnitId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="ItemTypeId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="Amount/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="ItemStateId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="ItemBarcode/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="ItemNote/@Value"/>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
