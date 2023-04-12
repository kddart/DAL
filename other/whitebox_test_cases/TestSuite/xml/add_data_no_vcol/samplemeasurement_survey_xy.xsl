<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="DATA">#TrialUnitId,SampleTypeId,TraitId,MeasurementDateTime,InstanceNumber,TraitValue,StateReason,SurveyId
<xsl:apply-templates select="ROW"/>
</xsl:template>

<xsl:template match="ROW">
  <xsl:value-of select="TrialUnitId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="SampleTypeId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="TraitId/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="MeasurementDateTime/@Value"/><xsl:text>,</xsl:text>
  <xsl:value-of select="InstanceNumber/@Value"/><xsl:text>,</xsl:text>
  <xsl:text>&quot;</xsl:text><xsl:value-of select="TraitValue/@Value"/><xsl:text>&quot;</xsl:text><xsl:text>,</xsl:text>
  <xsl:text>"</xsl:text><xsl:value-of select="StateReason/@Value"/><xsl:text>"</xsl:text><xsl:text>,</xsl:text>
  <xsl:value-of select="SurveyId/@Value"/><xsl:text>,</xsl:text>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:stylesheet>
