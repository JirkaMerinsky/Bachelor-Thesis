<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:nms="http://www.stormware.cz/schema/version_2/numericalSeries.xsd" expand-text="yes">
    <xsl:include href="numerical-series-common.xsl"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>
    <xsl:template match="lst:numericalSeries">
        <xsl:if test="nms:numericalSeriesHeader/nms:agenda = 'vydane_faktury'">
            <rada-faktury-vydane>
                <kod>VYDFAKT-{nms:numericalSeriesHeader/nms:id}</kod>
                <nazev>{nms:numericalSeriesHeader/nms:name}</nazev>
                <modul>FAV</modul>
            </rada-faktury-vydane>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>