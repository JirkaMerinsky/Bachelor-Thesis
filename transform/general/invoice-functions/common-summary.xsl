<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd" exclude-result-prefixes="xs" expand-text="yes"
    version="3.0">
    <xsl:function name="inf:commonSummary">
        <xsl:param name="invoiceSummary"/>
        <xsl:if test="$invoiceSummary/../not(*:invoiceDetail)">
            <xsl:choose>
                <xsl:when test="$invoiceSummary/*:foreignCurrency">
                    <!--        Foreign-->
                    <sumOsvMen>{$invoiceSummary/*:foreignCurrency/typ:priceSum}</sumOsvMen>
                    <kurzMnozstvi>{$invoiceSummary/*:foreignCurrency/typ:amount}</kurzMnozstvi>
                </xsl:when>
                <xsl:otherwise>
                    <!--        Home-->
                    <xsl:for-each select="$invoiceSummary/*:homeCurrency">
                    <sumOsv>{typ:priceNone}</sumOsv>
                    <!--                For high VAT (21%)-->
                    <sumCelkZakl>{typ:priceHighSum}</sumCelkZakl>
                    <!--                For low VAT (12% or 15%)-->
                    <sumCelkSniz>{typ:priceLowSum}</sumCelkSniz>
                    <!--                    For third VAT (10%)-->
                    <sumCelkSniz2>{typ:price3Sum}</sumCelkSniz2>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
