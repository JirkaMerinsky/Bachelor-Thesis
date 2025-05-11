<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd"
                xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd" expand-text="yes">

    <xsl:import href="general/functions.xsl"/>
    <xsl:param name="year"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>
    
    <xsl:template match="lAdb:addressbook">
        <xsl:apply-templates select="adb:addressbookAccount/adb:accountItem"/>
    </xsl:template>
    
    <xsl:template match="adb:addressbookAccount/adb:accountItem">
        <adresar-bankovni-ucet>
            <xsl:if test="adb:bankCode != ''">
                <id>ext:POHODA:{adb:id}</id>
                <buc>{adb:accountNumber}</buc>
                <smerKod>code:{adb:bankCode}</smerKod>
                <primarni>{adb:defaultAccount}</primarni>
                <firma>ext:POHODA:{../../adb:addressbookHeader/adb:id}</firma>
            </xsl:if>
        </adresar-bankovni-ucet>
    </xsl:template>
</xsl:stylesheet>
