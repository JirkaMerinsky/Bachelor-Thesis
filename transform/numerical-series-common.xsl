<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:nms="http://www.stormware.cz/schema/version_2/numericalSeries.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions">
    <xsl:include href="general/generate-id.xsl" expand-text="yes"/>

    <xsl:param name="year"/>
    <xsl:template match="nms:numericalSeriesHeader">
        <polozkyRady>
            <rocni-rada>
                <id>{gi:generateId(nms:id, $year, true(), false())}</id>
                <zobrazNuly>true</zobrazNuly>
                <cisDelka>{string-length(nms:number)}</cisDelka>
                <cisAkt>{nms:number}</cisAkt>
                <cisPoc>1</cisPoc>
                <prefix>{nms:prefix}</prefix>
                <ucetObdobi>code:{nms:year}</ucetObdobi>
            </rocni-rada>
        </polozkyRady>
    </xsl:template>

</xsl:stylesheet>
