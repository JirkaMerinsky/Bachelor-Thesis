<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:itf="http://www.dcos.cz/flexi-migration/invoice-functions/invoice-item"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs"
    expand-text="yes" version="3.0">
    <xsl:function name="itf:vatType">
        <xsl:param name="companyOpt"/>
        <xsl:param name="rateVat"/>
        <xsl:variable name="vatTypeMap" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:map-entry key="'high'" select="'typSzbDph.dphZakl'"/>
                <xsl:map-entry key="'low'" select="'typSzbDph.dphSniz'"/>
                <xsl:map-entry key="'third'" select="'typSzbDph.dphSniz2'"/>
                <xsl:map-entry key="'none'" select="'typSzbDph.dphOsv'"/>
            </xsl:map>
        </xsl:variable>
        <typSazbyDph>{map:get($vatTypeMap, $rateVat)}</typSazbyDph>
    </xsl:function>
</xsl:stylesheet>
