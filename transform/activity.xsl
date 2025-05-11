<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:lAcv="http://www.stormware.cz/schema/version_2/list_activity.xsd"
    xmlns:acv="http://www.stormware.cz/schema/version_2/activity.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lAcv:activity">
        <cinnost>
            <id>{gi:generateId(acv:activityHeader/acv:id, $year, true(), false())}</id>
            <kod>{upper-case(acv:activityHeader/acv:code)}</kod>
            <nazev>{acv:activityHeader/acv:name}</nazev>
        </cinnost>
    </xsl:template>

    <xsl:template match="lst:itemActivity">
        <cinnost>
            <id>{gi:generateId(@id, $year, true(), false())}</id>
            <kod>{@code}</kod>
            <nazev>{@name}</nazev>
        </cinnost>
        
    </xsl:template>


</xsl:stylesheet>
