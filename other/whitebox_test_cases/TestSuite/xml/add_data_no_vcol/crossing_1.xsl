<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="DATA">#TrialId,BreedingMethodId,MaleParentId,FemaleParentId
<xsl:apply-templates select="ROW"/>
</xsl:template>

<xsl:template match="ROW">
  <xsl:value-of select="TrialId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="BreedingMethodId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="MaleParentId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="FemaleParentId/@Value"/><xsl:text>,</xsl:text>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
