<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://www.dcos.cz/flexi-migration/functions"
                xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:ofr="http://www.stormware.cz/schema/version_2/offer.xsd"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd">

    <xsl:import href="general/document-common.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>

    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:offer">
        <nabidka-vydana>
            <xsl:apply-templates select="ofr:offerHeader"/>
            <xsl:apply-templates select="ofr:offerDetail"/>
            <xsl:sequence select="dc:generateDocumentSummary(ofr:offerDetail, ofr:offerSummary, false)"/>
        </nabidka-vydana>
    </xsl:template>


    <xsl:template match="ofr:offerHeader">
        <xsl:sequence
          select="dc:generateCommonHeaderNodes(current(), ../ofr:offerSumarry, $vat-mapping, $account-assignment_flexi, $year, 'OUTGOING')"/>
        <typDokl>code:NAV</typDokl>
        <datTermin>
            <xsl:value-of select="ofr:validTill"/>
        </datTermin>
        <xsl:choose>
            <xsl:when test="ofr:isExecuted ='true'">
                <stavUzivK>stavDoklObch.hotovo</stavUzivK>
            </xsl:when>
            <xsl:otherwise>
                <stavUzivK>stavDoklObch.nespec</stavUzivK>
            </xsl:otherwise>
        </xsl:choose>
        <popis>
            <xsl:value-of select="f:textSubstring(ofr:text,255)"/>
        </popis>
        <xsl:if test="ofr:centre/typ:ids">
            <stredisko>
                <xsl:value-of select="concat('code:', upper-case(ofr:centre/typ:ids))"/>
            </stredisko>
        </xsl:if>
        <xsl:if test="ofr:activity/typ:ids">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(ofr:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ofr:offerDetail">
        <polozkyObchDokladu removeAll="true">
            <xsl:apply-templates select="ofr:offerItem"/>
        </polozkyObchDokladu>
    </xsl:template>

    <xsl:template match="ofr:offerItem">
        <nabidka-vydana-polozka>
            <id>ext:POHODA:<xsl:value-of select="concat(ofr:id, '-', $year)"/>
            </id>
            <mnozMj>
                <xsl:value-of select="f:validateAndTrimNumber(ofr:quantity,19)"/>
            </mnozMj>
            <xsl:sequence
              select="dc:generateCommonItemNodes(current(), ../../ofr:offerSummary, $vat-mapping, $account-assignment_flexi, $year)"/>
            <xsl:if test="ofr:centre/typ:ids">
                <stredisko>
                    <xsl:value-of select="concat('code:', upper-case(ofr:centre/typ:ids))"/>
                </stredisko>
            </xsl:if>
            <xsl:if test="ofr:activity/typ:ids">
                <cinnost>
                    <xsl:value-of select="concat('code:', upper-case(ofr:activity/typ:ids))"/>
                </cinnost>
            </xsl:if>
        </nabidka-vydana-polozka>
    </xsl:template>


</xsl:stylesheet>