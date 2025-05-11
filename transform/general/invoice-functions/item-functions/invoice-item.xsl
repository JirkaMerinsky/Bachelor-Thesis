<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:itf="http://www.dcos.cz/flexi-migration/invoice-functions/invoice-item"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd" exclude-result-prefixes="xs"
    expand-text="yes" version="3.0">
    <xsl:include href="../../generate-id.xsl"/>
    <xsl:include href="vat-type.xsl"/>
    <xsl:include href="item-price.xsl"/>
    <xsl:function name="itf:invoiceItem">
        <xsl:param name="year"/>
        <xsl:param name="itemNode"/>
        <xsl:param name="isInvoice"/>
        <xsl:if test="$itemNode/*:quantity > 0">
            <id>{gi:generateId($itemNode/*:id, $year, true(), false())}</id>
            <nazev>{$itemNode/*:text}</nazev>
            <mnozMj>{$itemNode/*:quantity}</mnozMj>
            <xsl:choose>
                <xsl:when test="$itemNode/*:unit != '' and $itemNode/*:unit != ' '">
                    <mj>code:{upper-case($itemNode/*:unit)}</mj>
                </xsl:when>
                <xsl:otherwise>
                    <mj>code:KS</mj>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$isInvoice">
                    <typPolozkyK>typPolozky.obecny</typPolozkyK>
                </xsl:when>
                <xsl:otherwise>
                    <typPolozkyK>typPolozky.ucetni</typPolozkyK>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:sequence select="itf:vatType((), $itemNode/*:rateVAT)"/>
            <szbDph>{$itemNode/*:rateVAT/@value}</szbDph>
            <xsl:if test="$itemNode/*:contract">
                <zakazka>code:{$itemNode/*:contract}</zakazka>
            </xsl:if>
            <xsl:if test="$itemNode/*:activity">
                <cinnost>code:{upper-case($itemNode/*:activity/*:ids)}</cinnost>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$itemNode/*:payVAT = 'true'">
                    <typCenyDphK>typCeny.sDph</typCenyDphK>
                </xsl:when>
                <xsl:otherwise>
                    <typCenyDphK>typCeny.bezDph</typCenyDphK>
                </xsl:otherwise>
            </xsl:choose>
            <slevaPol>{$itemNode/*:discountPercentage}</slevaPol>
            <xsl:sequence select="itf:itemPricing($itemNode)"/>
            <xsl:choose>
                <xsl:when test="
                        $itemNode/*:accounting and $itemNode/*:accounting/typ:ids != 'Bez'
                        and $itemNode/*:accounting/typ:ids
                        != 'Ručně'">
                    <typUcOp>{gi:generateId($itemNode/*:accounting/typ:id, $year, true(),
                        false())}</typUcOp>
                    <kopTypUcOp>false</kopTypUcOp>
                </xsl:when>
                <xsl:otherwise>
                    <kopTypUcOp>true</kopTypUcOp>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="$itemNode/*:centre">
                <stredisko>code:{upper-case($itemNode/*:centre/typ:ids)}</stredisko>
            </xsl:if>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
