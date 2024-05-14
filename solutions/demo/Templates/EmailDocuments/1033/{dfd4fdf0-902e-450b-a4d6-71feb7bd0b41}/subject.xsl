<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" indent="no" />
  <xsl:template match="/data">
    <xsl:choose>
      <xsl:when test="incident/title">
        <xsl:value-of select="incident/title" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose><![CDATA[[Case Number:]]><xsl:choose>
      <xsl:when test="incident/ticketnumber">
        <xsl:value-of select="incident/ticketnumber" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose><![CDATA[] ]]>
  </xsl:template>
</xsl:stylesheet>