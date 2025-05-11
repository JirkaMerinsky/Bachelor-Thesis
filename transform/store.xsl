<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:sto="http://www.stormware.cz/schema/version_2/store.xsd" xmlns:json="http://json.org/"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:store">
        <sklad>
            <id>{gi:generateId(sto:id, $year, true(), false())}</id>
            <kod>{sto:name}</kod>
            <nazev>{sto:text}</nazev>
            <poznam>{sto:note}</poznam>
            <!-- I think default value should be false since Pohoda does not have it -->
            <automatickySklad>false</automatickySklad>
            <modul>SKL</modul>
            <radaPrijem>code:SKLAD+</radaPrijem>
            <radaVydej>code:SKLAD-</radaVydej>
        </sklad>
    </xsl:template>

</xsl:stylesheet>
