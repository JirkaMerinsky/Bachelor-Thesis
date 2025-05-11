<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:json="http://json.org/"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:lCen="http://www.stormware.cz/schema/version_2/list_centre.xsd"
                xmlns:cen="http://www.stormware.cz/schema/version_2/centre.xsd" expand-text="yes"
>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:itemCentre">
        <stredisko>
            <id>ext:POHODA:{@id}</id>
            <kod>{@code}</kod>
            <nazev>{@name}</nazev>
        </stredisko>
    </xsl:template>
<!--    Center -->
    <xsl:template match="lCen:centre">
        <stredisko>
            <id>ext:POHODA:{cen:centreHeader/cen:id}</id>
            <kod>{upper-case(cen:centreHeader/cen:code)}</kod>
            <nazev>{cen:centreHeader/cen:name}</nazev>
        </stredisko>
    </xsl:template>
</xsl:stylesheet>