<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:itf="http://www.dcos.cz/flexi-migration/invoice-functions/invoice-item"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd" exclude-result-prefixes="xs"
    expand-text="yes" version="3.0">
    <xsl:function name="itf:itemPricing">
        <xsl:param name="itemNode"/>
        <xsl:choose>
            <xsl:when test="$itemNode/*:foreignCurrency">
                <xsl:for-each select="$itemNode/*:foreignCurrency">
                    <cenaMj>{typ:unitPrice}</cenaMj>
                    <sumCelkemMen>{typ:priceSum}</sumCelkemMen>
                    <sumDph>{*:priceVAT}</sumDph>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$itemNode/*:homeCurrency">
                    <cenaMj>{typ:unitPrice}</cenaMj>
                    <sumCelkem>{typ:priceSum}</sumCelkem>
                    <sumDph>{*:priceVAT}</sumDph>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>


