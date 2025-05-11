<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:csh="http://www.stormware.cz/schema/version_2/cashRegister.xsd"
    xmlns:json="http://json.org/" xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/document-common.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:cashRegister">
        <pokladna json:force-array="true">
            <xsl:apply-templates select="csh:cashRegisterHeader"/>
        </pokladna>
    </xsl:template>

    <xsl:template match="csh:cashRegisterHeader"><id>{gi:generateId(csh:id, $year, true(), false())}</id>
        <kod>{csh:ids}</kod>
        <nazev>{csh:name}</nazev>
        <poznam>{csh:note}</poznam>
        <xsl:if test="csh:centre/typ:ids">
            <stredisko>code:{upper-case(csh:centre/typ:ids)}</stredisko>
        </xsl:if>
        <xsl:if test="csh:activity/typ:ids">
            <cinnost>code:{upper-case(csh:activity/typ:ids)}</cinnost>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="csh:account/typ:ids">
                <primUcet>code:{csh:account/typ:ids}</primUcet>
            </xsl:when>
            <xsl:otherwise>
                <primUcet>code:211000</primUcet>
            </xsl:otherwise>
        </xsl:choose>
        <radaPrijem>code:POKLADNA+</radaPrijem>
        <radaVydej>code:POKLADNA-</radaVydej>

        <xsl:choose>
            <xsl:when test="csh:currencyCashRegister/csh:currency/typ:ids">
                <mena>code:{csh:currencyCashRegister/csh:currency/typ:ids}</mena>
            </xsl:when>
            <xsl:otherwise>
                <mena>code:CZK</mena>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>
        <xsl:variable name="idsPath">{csh:accounting/typ:ids}</xsl:variable>
        <xsl:sequence select="dc:insertAccounts($idsPath, $account-assignment_flexi)"/>
    </xsl:template>
</xsl:stylesheet>
