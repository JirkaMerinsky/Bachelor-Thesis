<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd"
                xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:gi="http://www.dcos.cz/flexi-migration/functions">
    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>

    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <!--TODO figure out how to put folder path as param -->
    <xsl:param name="folderPath"
               select="concat('C', ':', '/', 'Users', '/', 'zbynstuc', '/', 'dCOS', '/', 'projects', '/', 'flexiMigration', '/', 'backend', '/', 'src', '/', 'main', '/', 'resources', '/', 'static', '/', 'download', '/', 'zbyna', '/')"/>
    <xsl:variable name="adresar" select="document(concat($folderPath, 'year_2022/' ,'addressbook_POHODA'))"/>


    <!--cenove urovne-->
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:itemSellingPrice">
        <cenova-uroven>
            
            
            <xsl:sequence select="gi:generateId(lst:id, $year, true(), false())"></xsl:sequence>
            <kod>
                <xsl:value-of select="upper-case(lst:code)"/>
            </kod>
            <nazev>
                <xsl:value-of select="lst:name"/>
            </nazev>
            <docasnost>
                <xsl:choose>
                    <xsl:when test="lst:discountValidity = 'permanent'">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </docasnost>
            <typVypCenyK>
                <xsl:if test="lst:margin">typVypCeny.marze</xsl:if>
                <xsl:if test="lst:discountPercentage">typVypCeny.sleva</xsl:if>
                <!--                <xsl:if test="lst:discountPercentage">typVypCeny.rabat</xsl:if>-->
            </typVypCenyK>
            <!--            TODO find out how to distinguish price type in POHODA - now use zakl cena always-->
            <typCenyVychoziK>typCenyVychozi.zaklCena</typCenyVychoziK>
            <procZakl>
                <xsl:if test="lst:margin">
                    <xsl:value-of select="lst:margin"/>
                </xsl:if>
                <xsl:if test="lst:discountPercentage">
                    <xsl:value-of select="lst:discountPercentage"/>
                </xsl:if>
            </procZakl>
            <zaokrJakK>zaokrJak.matem</zaokrJakK>
            <zaokrNaK>
                <xsl:variable name="rounding-map" as="map(xs:string, xs:string)" select="map {
                    '0,001' : 'zaokrNa.tisiciny',
                    '0,01'  : 'zaokrNa.setiny',
                    '0,05'  : 'zaokrNa.5setiny',
                    '0,1'   : 'zaokrNa.desetiny',
                    '0,5'   : 'zaokrNa.5desetiny',
                    '1'     : 'zaokrNa.jednotky',
                    '5'     : 'zaokrNa.5jednotky',
                    '10'    : 'zaokrNa.desitky',
                    '100'   : 'zaokrNa.stovky',
                    '1000'  : 'zaokrNa.tisice'
                    }"/>
                <xsl:variable name="rounding-key" select="string(lst:rounding)"/>
                <xsl:value-of select="
                    if (map:contains($rounding-map, $rounding-key)) 
                    then $rounding-map($rounding-key)
                    else 'zaokrNa.zadne'
                    "/>
            </zaokrNaK>

            <vsechnySkupZboz>true</vsechnySkupZboz>
            <vsechnyFirmy>false</vsechnyFirmy>

            <!--            Add firmy to each cenova-uroven-->
            <xsl:variable name="code" select="lst:code"/>
            <firmy>
                <xsl:for-each select="$adresar/*/*/*/lAdb:addressbook">

                    <xsl:if test="adb:addressbookHeader/adb:priceIDS = $code">
                        <adresar>
                            <id>
                                <xsl:value-of select="concat('ext:POHODA:', adb:addressbookHeader/adb:id, '-', $year)"/>
                            </id>
                        </adresar>
                    </xsl:if>

                </xsl:for-each>
            </firmy>
        </cenova-uroven>
    </xsl:template>
</xsl:stylesheet>
