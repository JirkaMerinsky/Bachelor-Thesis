<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://www.dcos.cz/flexi-migration/functions"
                xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
                xmlns:ord="http://www.stormware.cz/schema/version_2/order.xsd">

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

    <xsl:template match="lst:order">
        <objednavka-vydana>
            <xsl:apply-templates select="ord:orderHeader"/>
            <xsl:apply-templates select="ord:orderDetail"/>
            <xsl:sequence select="dc:generateDocumentSummary(ord:orderDetail, ord:orderSummary, false)"/>
        </objednavka-vydana>
    </xsl:template>

    <xsl:template match="ord:orderHeader">

        <xsl:sequence
          select="dc:generateCommonHeaderNodes(current(), ../inv:invoiceSummary, $vat-mapping, $account-assignment_flexi, $year, 'OUTGOING')"/>

        <popis>
            <xsl:value-of select="f:textSubstring(ord:text,255)"/>
        </popis>
        <typDokl>code:OBV</typDokl>
        <kontaktJmeno>
            <xsl:value-of
              select="f:textSubstring(concat(ord:myIdentity/typ:address/typ:name, ' ', ord:myIdentity/typ:address/typ:surname),255)"/>
        </kontaktJmeno>
        <kontaktEmail>
            <xsl:value-of select="f:textSubstring(ord:myIdentity/typ:address/typ:email,255)"/>
        </kontaktEmail>
        <kontaktTel>
            <xsl:value-of select="f:textSubstring(ord:myIdentity/typ:address/typ:phone,255)"/>
        </kontaktTel>
        <rada if-not-found="null">code:OBV</rada>

        <xsl:choose>
            <xsl:when test="ord:isExecuted ='true'">
                <stavUzivK showAs="Hotovo">stavDoklObch.hotovo</stavUzivK>
            </xsl:when>
            <xsl:otherwise>
                <stavUzivK showAs="Nespecifikováno">stavDoklObch.nespec</stavUzivK>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="ord:centre/typ:ids">
            <stredisko>
                <xsl:value-of select="concat('code:', upper-case(ord:centre/typ:ids))"/>
            </stredisko>
        </xsl:if>
        <xsl:if test="ord:activity/typ:ids">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(ord:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>
    </xsl:template>


    <xsl:template match="ord:orderDetail">
        <polozkyObchDokladu>
            <xsl:apply-templates select="ord:orderItem"/>
        </polozkyObchDokladu>
    </xsl:template>

    <xsl:template match="ord:orderItem">
        <objednavka-vydana-polozka>
            <id>ext:POHODA:<xsl:value-of select="concat(ord:id, '-', $year)"/>
            </id>
            <mnozMj>
                <xsl:value-of select="f:validateAndTrimNumber(ord:quantity,19)"/>
            </mnozMj>
            <xsl:sequence
              select="dc:generateCommonItemNodes(current(), ../../ord:orderSummary, $vat-mapping, $account-assignment_flexi, $year)"/>
            <xsl:if test="ord:centre/typ:ids">
                <stredisko>
                    <xsl:value-of select="concat('code:', upper-case(ord:centre/typ:ids))"/>
                </stredisko>
            </xsl:if>
            <xsl:if test="ord:activity/typ:ids">
                <cinnost>
                    <xsl:value-of select="concat('code:', upper-case(ord:activity/typ:ids))"/>
                </cinnost>
            </xsl:if>
        </objednavka-vydana-polozka>
    </xsl:template>


</xsl:stylesheet>
