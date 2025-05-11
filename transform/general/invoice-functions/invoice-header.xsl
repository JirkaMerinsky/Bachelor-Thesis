<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd" exclude-result-prefixes="xs"
    version="3.0" expand-text="yes">
    <xsl:function name="inf:header">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="invoiceHeader" as="node()"/>
        <xsl:param name="addressbook"/>
        <xsl:variable name="ucetni" select="not(contains($invoiceHeader/*:accounting/*:ids, 'BEZ'))"/>
        <ucetni>
            <xsl:sequence select="$ucetni"/>
        </ucetni>
        <xsl:if test="$invoiceHeader/*:activity">
            <cinnost>
                <xsl:sequence select="'code:' || upper-case($invoiceHeader/*:activity/*:ids)"/>
            </cinnost>
        </xsl:if>
        <kod>{$invoiceHeader/*:number/typ:numberRequested}</kod>
        <cisDosle>
            <xsl:choose>
                <!--                Received invoice shall use original document number -->
                <xsl:when test="$invoiceHeader/*:originalDocument"
                    >{$invoiceHeader/*:originalDocument}</xsl:when>
                <xsl:otherwise>
                    <!--                    If original document number is missing, use variable symbol instead-->
                    <xsl:choose>
                        <xsl:when test="$invoiceHeader/*:symVar"
                            >{$invoiceHeader/*:symVar}</xsl:when>
                        <xsl:otherwise>{$invoiceHeader/*:number/typ:numberRequested}</xsl:otherwise>
                    </xsl:choose>

                </xsl:otherwise>
            </xsl:choose>
        </cisDosle>
        <xsl:if test="$invoiceHeader/*:symConst">
            <konSym>code:{$invoiceHeader/*:symConst}</konSym>
        </xsl:if>
        <!--        Variable symbol-->
        <varSym>{$invoiceHeader/*:symVar}</varSym>
        <xsl:if test="$invoiceHeader/*:contract">
            <zakazka>code:{$invoiceHeader/*:contract}</zakazka>
        </xsl:if>
        <datVyst>{$invoiceHeader/*:date}</datVyst>
        <datSazbyDph>{$invoiceHeader/*:dateTax}</datSazbyDph>
        <datTermin>{$invoiceHeader/*:dateDue}</datTermin>
        <datSplat>{$invoiceHeader/*:dateDue}</datSplat>
        <xsl:choose>
            <xsl:when test="$invoiceHeader/*:dateKHDPH">
                <duzpUcto>{$invoiceHeader/*:dateTax}</duzpUcto>
                <duzpPuv>{$invoiceHeader/*:dateKHDPH}</duzpPuv>
            </xsl:when>
            <xsl:otherwise>
                <duzpUcto>{$invoiceHeader/*:dateAccounting}</duzpUcto>
                <duzpPuv>{$invoiceHeader/*:dateTax}</duzpPuv>
            </xsl:otherwise>
        </xsl:choose>
        <popis>{$invoiceHeader/*:text}</popis>
        <kontaktJmeno>{$invoiceHeader/*:partnerIdentity/typ:address/typ:name}</kontaktJmeno>
        <kontaktEmail>{$invoiceHeader/*:partnerIdentity/typ:address/typ:email}</kontaktEmail>
        <kontaktTel>{$invoiceHeader/*:partnerIdentity/typ:address/typ:phone}</kontaktTel>
        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>
        <xsl:if test="$invoiceHeader/*:centre">
            <stredisko>code:{upper-case($invoiceHeader/*:centre/typ:ids)}</stredisko>
        </xsl:if>
    </xsl:function>
</xsl:stylesheet>
