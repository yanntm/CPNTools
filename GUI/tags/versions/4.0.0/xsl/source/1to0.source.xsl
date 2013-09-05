<?xml version="1.0"?>

<!-- 
 ! NOTE: This file does not work! It needs to be extended to include all
 ! the needed transformations to convert from "old" CPNTools format to
 ! Design/CPN 
-->

<xsl:stylesheet xmlns:loop="http://informatik.hu-berlin.de/loop" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="loop">

  <xsl:output method="xml"
              encoding="iso-8859-1"
              omit-xml-declaration="no"
              indent="yes"/>

  <xsl:template match="comment()"/>

  <xsl:template match="generator"/>

  <xsl:template match="workspaceElements">
    <workspaceElements>
      <generator tool="Converter" version="0" format="0"/>
      <xsl:apply-templates select="cpnet"/>
    </workspaceElements>
  </xsl:template>

  <xsl:template match="@*|node()"
                priority="-10000">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
