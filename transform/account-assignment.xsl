<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
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

    <xsl:template match="lst:itemAccounting">
        <predpis-zauctovani>
            <id>{gi:generateId(@id, $year, false(), false())}</id>

            <kod>ext:POHODA:{@id}</kod>
            <nazev>{@accounting}</nazev>
            <xsl:choose>
                <xsl:when test="@agenda = 'issuedInvoice'">
                    <modulFav>true</modulFav>
                </xsl:when>
                <xsl:when test="@agenda = 'receivedInvoice'">
                    <modulFap>true</modulFap>
                </xsl:when>
                <xsl:when test="@agenda = 'bankIssued'">
                    <modulBanV>true</modulBanV>
                </xsl:when>
                <xsl:when test="@agenda = 'bankReceived'">
                    <modulBanP>true</modulBanP>
                </xsl:when>
                <xsl:when test="@agenda = 'claim'">
                    <modulPhl>true</modulPhl>
                </xsl:when>
                <xsl:when test="@agenda = 'commitment'">
                    <modulZav>true</modulZav>
                </xsl:when>
                <xsl:when test="@agenda = 'cashReceived'">
                    <modulPokP>true</modulPokP>
                </xsl:when>
                <xsl:when test="@agenda = 'cashPaid'">
                    <modulPokV>true</modulPokV>
                </xsl:when>
                <xsl:when test="@agenda = 'internalDocument'">
                    <modulInt>true</modulInt>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@debit != ''">
                <protiUcetPrijem>code:{@debit}</protiUcetPrijem>
            </xsl:if>
            <xsl:if test="@credit != ''">
                <protiUcetVydej>code:{@credit}</protiUcetVydej>
            </xsl:if>
        </predpis-zauctovani>
    </xsl:template>
</xsl:stylesheet>
