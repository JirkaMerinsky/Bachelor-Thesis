<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:ic="http://www.dcos.cz/flexi-migration/document-common" exclude-result-prefixes="xs"
    expand-text="yes" version="3.0">
    <xsl:function name="inf:companyFuntion">
        <xsl:param name="partnerAddress"/>
        <xsl:param name="invoiceHeader"/>
        <xsl:choose>
            <xsl:when test="
                    count($partnerAddress/*:addressbook[
                    *:addressbookHeader/*:id = $invoiceHeader/*:partnerIdentity/*:id]) > 0">
                <firma>
                    <xsl:sequence select="'ext:POHODA:' || $invoiceHeader/*:partnerIdentity/*:id"/>
                </firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="
                            count($partnerAddress/*:addressbook[
                            *:addressbookHeader/*:identity/*:address/*:company =
                            $invoiceHeader/*:partnerIdentity/*:address/*:company
                            ]) >= 1
                            or
                            count($partnerAddress/*:addressbook[
                            *:addressbookHeader/*:identity/*:address/*:name =
                            $invoiceHeader/*:partnerIdentity/*:address/*:name
                            ]) >= 1
                            ">
                        <xsl:choose>
                            <xsl:when test="
                                    $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                    and count($partnerAddress/*:addressbook/
                                    *:addressbookHeader[*:identity/*:address/*:ico =
                                    $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                    ]) = 1">
                                <firma>
                                    <xsl:sequence select="
                                            'ext:POHODA:' || $partnerAddress/*:addressbook/
                                            *:addressbookHeader[*:identity/*:address/*:ico =
                                            $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                            ]/*:id"/>
                                </firma>
                            </xsl:when>
                            <xsl:when test="
                                    $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                    and count($partnerAddress/*:addressbook/
                                    *:addressbookHeader[*:identity/*:address/*:ico =
                                    $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                    ]) > 1">
                                <firma>
                                    <xsl:sequence select="
                                            'ext:POHODA:' || $partnerAddress/*:addressbook/
                                            *:addressbookHeader[*:identity/*:address/*:ico =
                                            $invoiceHeader/*:partnerIdentity/*:address/*:ico
                                            and
                                            *:identity/*:address/*:company =
                                            $invoiceHeader/*:partnerIdentity/*:address/*:company
                                            ]/*:id"/>
                                </firma>
                            </xsl:when>

                            <xsl:when test="
                                    $invoiceHeader/*:partnerIdentity/*:address/*:dic
                                    and
                                    not($invoiceHeader/*:partnerIdentity/*:address/*:ico)">
                                <firma>
                                    <xsl:sequence select="
                                            'ext:POHODA:' || $partnerAddress/*:addressbook/
                                            *:addressbookHeader[*:identity/*:address/*:dic =
                                            $invoiceHeader/*:partnerIdentity/*:address/*:dic
                                            and
                                            *:identity/*:address/*:company =
                                            $invoiceHeader/*:partnerIdentity/*:address/*:company
                                            ]/*:id"/>
                                </firma>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:sequence select="ic:manualFillPartnerIdentity($invoiceHeader)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:sequence select="ic:manualFillPartnerIdentity($invoiceHeader)"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ic:manualFillPartnerIdentity">
        <xsl:param name="invoiceHeader"/>
        <xsl:choose>
            <xsl:when test="$invoiceHeader/*:partnerIdentity/typ:address/typ:company">
                <nazFirmy>{$invoiceHeader/*:partnerIdentity/typ:address/typ:company}</nazFirmy>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>{$invoiceHeader/*:partnerIdentity/typ:address/typ:name}</nazFirmy>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="$invoiceHeader/*:partnerIdentity/typ:address">
            <ulice>{typ:street}</ulice>
            <mesto>{typ:city}</mesto>
            <psc>{typ:zip}</psc>
            <ic>{typ:ico}</ic>
            <dic>{typ:dic}</dic>
            <kontaktJmeno>{typ:name}</kontaktJmeno>
            <kontaktEmail>{typ:email}</kontaktEmail>
            <kontaktTel>{typ:phone}</kontaktTel>
        </xsl:for-each>
        <xsl:if test="$invoiceHeader/*:partnerIdentity/typ:address/typ:country/typ:ids">
            <stat>code:{$invoiceHeader/*:partnerIdentity/typ:address/typ:country/typ:ids}</stat>
        </xsl:if>

    </xsl:function>
</xsl:stylesheet>
