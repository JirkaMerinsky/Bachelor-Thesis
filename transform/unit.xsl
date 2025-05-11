<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" expand-text="yes">
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>
    <xsl:template match="item">
        <merna-jednotka>
            <id>ext:POHODA:{id}</id>
            <kod>{upper-case(code)}</kod>
            <nazev>{text}</nazev>
        </merna-jednotka>
    </xsl:template>

</xsl:stylesheet>