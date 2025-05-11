<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    exclude-result-prefixes="xs" version="3.0">
    <xsl:function name="inf:paymentType">
        <xsl:param name="paymentId"/>
        <xsl:variable name="paymentMap" as="map(xs:string, xs:string)">
            <xsl:map>
                <xsl:map-entry key="'1'" select="'code:PREVOD'"/>
                <xsl:map-entry key="'2'" select="'code:HOTOVE'"/>
                <xsl:map-entry key="'4'" select="'code:DOBIRKA'"/>
                <xsl:map-entry key="'5'" select="'code:KARTA'"/>
                <xsl:map-entry key="'7'" select="'code:INKASEM'"/>
                <xsl:map-entry key="'9'" select="'code:ZAPOCET'"/>
            </xsl:map>
        </xsl:variable>
        <formaUhradyCis>
            <xsl:sequence select="
                if (map:contains($paymentMap, $paymentId)) 
                then map:get($paymentMap, $paymentId) 
                else 'code:NESPECIFIKOVANO'"/>
        </formaUhradyCis>
    </xsl:function>
</xsl:stylesheet>
