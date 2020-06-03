<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="utf-8"/>

  <xsl:template match="/*[node()]">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates select="." mode="detect" />
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="*" mode="detect">
    <xsl:choose>
      <xsl:when test="name(preceding-sibling::*[1]) != name(current())">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>" : </xsl:text>
        <xsl:if test="(parent::*)">[</xsl:if>
        <xsl:apply-templates select="." mode="obj-content" />
        <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
        <xsl:if test="count(following-sibling::*) = 0  and (parent::*)">]</xsl:if>
      </xsl:when>
      <xsl:when test="name(preceding-sibling::*[1]) = name(current())">
        <xsl:apply-templates select="." mode="obj-content" />
        <xsl:if test="name(following-sibling::*) = name(current())">, </xsl:if>
        <xsl:if test="name(following-sibling::*) != name(current()) and (parent::*)">]</xsl:if>
      </xsl:when>
      <xsl:when test="count(./child::*) > 0 or count(@*) > 0">
        <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : <xsl:apply-templates select="." mode="obj-content" />
        <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
      </xsl:when>
      <xsl:when test="count(./child::*) = 0">
        <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : "<xsl:apply-templates select="."/><xsl:text>"</xsl:text>
        <xsl:if test="count(following-sibling::*) &gt; 0">, </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="obj-content">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates select="@*" mode="attr" />
    <xsl:if test="count(@*) &gt; 0 and (count(child::*) &gt; 0 or text())">, </xsl:if>
    <xsl:apply-templates select="./*" mode="detect" />
    <xsl:if test="count(child::*) = 0 and text() and not(@*)">
      <xsl:text>"</xsl:text><xsl:value-of select="name()"/>" : "<xsl:value-of select="text()"/><xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:if test="count(child::*) = 0 and text() and @*">
      <xsl:text>"text" : "</xsl:text>
      <xsl:value-of select="text()"/>
      <xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:text>}</xsl:text>
    <xsl:if test="position() &lt; last()">, </xsl:if>
  </xsl:template>

  <!-- attribute -->
  <xsl:template match="@*" mode="attr">
    <xsl:text>"</xsl:text><xsl:value-of select="translate(name(), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>" : "<xsl:call-template name="escapeQuote" /><xsl:text>"</xsl:text>
    <xsl:if test="position() &lt; last()">,</xsl:if>
  </xsl:template>

  <xsl:template name="escapeQuote">
    <xsl:param name="pText" select="concat(normalize-space(.), '')" />
    <xsl:if test="string-length($pText) > 0">
      <xsl:value-of select="substring-before(concat($pText, '&quot;'), '&quot;')" />
      <xsl:if test="contains($pText, '&quot;')">
        <xsl:text>\"</xsl:text>
        <xsl:call-template name="escapeQuote">
          <xsl:with-param name="pText" select="substring-after($pText, '&quot;')" />
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>