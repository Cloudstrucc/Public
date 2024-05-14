<?xml version="1.0" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text" indent="no"/>
  <xsl:template match="/data">
    <![CDATA[<P>Dear ]]><xsl:choose>
      <xsl:when test="incident/customerid/@name">
        <xsl:value-of select="incident/customerid/@name" />
      </xsl:when>
      <xsl:otherwise>Valued Customer</xsl:otherwise>
    </xsl:choose><![CDATA[,</P> <P>We have opened a case ]]><xsl:choose>
      <xsl:when test="incident/title">
        <xsl:value-of select="incident/title" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose><![CDATA[ for your request. One of our customer service representatives will contact you shortly.</P><P> Should you need to follow up on this case, please contact us with this reference  ]]><xsl:choose>
      <xsl:when test="incident/ticketnumber">
        <xsl:value-of select="incident/ticketnumber" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose><![CDATA[ We will do our best to resolve this case as soon as possible.</P><P>Thank you</P> ]]>
  </xsl:template>
</xsl:stylesheet>