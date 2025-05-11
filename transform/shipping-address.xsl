<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd"
                xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd" xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lAdb:addressbook">
        <xsl:apply-templates select="adb:addressbookHeader/adb:identity"/>
    </xsl:template>

    <xsl:template match="adb:addressbookHeader/adb:identity">

        <xsl:for-each select="typ:shipToAddress">
            <xsl:if test="typ:company">

                <misto-urceni>
                    <id>{gi:generateId(typ:id, $year, true(), false())}</id>
                    <ulice>{typ:street}</ulice>
                    <mesto>{typ:city}</mesto>
                    <psc>{typ:zip}</psc>
                    <xsl:if test="typ:country/typ:ids">
                        <stat if-not-found="create">code:{typ:country/typ:ids}</stat>
                    </xsl:if>
                    <tel>{typ:phon}</tel>
                    <mobil>{typ:mobilPhone}</mobil>
                    <fax>{typ:fax}</fax>
                    <email>{typ:email}</email>
                    <www>{typ:link}</www>
                    <firma>ext:POHODA:{../../adb:id}</firma>
                    <nazev>{typ:company}</nazev>
                </misto-urceni>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
