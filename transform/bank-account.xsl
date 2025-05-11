<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:bka="http://www.stormware.cz/schema/version_2/bankAccount.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:bankAccount">
        <bankovni-ucet json:force-array="true">
            <xsl:apply-templates select="bka:bankAccountHeader"/>
        </bankovni-ucet>
    </xsl:template>

    <xsl:template match="bka:bankAccountHeader">
        <id>{gi:generateId(bka:id, $year, true(), false())}</id>
        <kod>{upper-case(bka:ids)}</kod>
        <nazev>{bka:nameBank}</nazev>
        <nazBanky>{bka:nameBank}</nazBanky>
        <smerKod>code:{bka:codeBank}</smerKod>
        <xsl:if test="bka:analyticAccount">
            <primUcet>code:{bka:analyticAccount/typ:ids}</primUcet>
        </xsl:if>
        <!--        TODO how to decide which stredisko to use-->
        <stredisko>code:C</stredisko>
        <radaPrijem>code:BANKA+</radaPrijem>
        <radaVydej>code:BANKA-</radaVydej>
        <buc>
            <xsl:value-of select="bka:numberAccount"/>
        </buc>
        <smerKod>code:{bka:codeBank}</smerKod>
        <iban>{bka:IBAN}</iban>
        <bic>{bka:SWIFT}</bic>
        <xsl:choose>
            <xsl:when test="bka:currencyBankAccount/bka:currency/typ:ids">
                <menaBanky>code:{bka:currencyBankAccount/bka:currency/typ:ids}</menaBanky>
                <mena>code:{bka:currencyBankAccount/bka:currency/typ:id}</mena>
            </xsl:when>
            <xsl:otherwise>
                <menaBanky>code:CZK</menaBanky>
                <mena>code:CZK</mena>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
