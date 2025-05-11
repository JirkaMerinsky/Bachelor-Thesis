<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lStk="http://www.stormware.cz/schema/version_2/list_stock.xsd"
    xmlns:stk="http://www.stormware.cz/schema/version_2/stock.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>
    <xsl:param name="standard-account_flexi"/>
    <xsl:param name="account_flexi"/>
    <xsl:param name="year"/>

    <!--    comment-->
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lStk:stock">
        <xsl:if test="stk:stockHeader/stk:producer">
            <id>{gi:generateId(stk:stockHeader/stk:id, $year, true(), false())}</id>
            <code>{stk:stockHeader/stk:id}</code>
            <name>{stk:stockHeader/stk:name}</name>
            <producer>{stk:stockHeader/stk:producer}</producer>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
