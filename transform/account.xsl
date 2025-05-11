<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>
    <xsl:param name="standard-account_flexi"/>
    <xsl:param name="account_flexi"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="item">
        <xsl:if test="./pouzivan = 'true'">
            <ucet>
                <xsl:variable name="code" select="accountCode"/>
                <xsl:variable name="substring_code" select="substring($code, 0, 4)"/>
                <xsl:variable name="accountFlexi"
                    select="document($standard-account_flexi)/winstrom/ucetni-osnova[kod = substring($code, 0, 4)]"/>
                <xsl:variable name="standard_account_code" select="$accountFlexi/kod"/>
                <xsl:variable name="standard_account_type" select="$accountFlexi/typUctuK"/>
                <xsl:variable name="standard_account_kind" select="$accountFlexi/druhUctuK"/>
                <xsl:variable name="existing_id"
                    select="document($account_flexi)/winstrom/ucet[kod = $code and not(contains(id, 'ext:POHODA'))]/id"/>
                <xsl:choose>
                    <xsl:when test="$existing_id">
                        <id>ext:POHODA:{$existing_id}</id>
                    </xsl:when>
                    <xsl:otherwise>
                        <id>ext:POHODA:{$code}</id>
                    </xsl:otherwise>
                </xsl:choose>
                <kod>{$code}</kod>
                <nazev>{name}</nazev>
                <danovy>false</danovy>
                <!-- TODO how to decifer from pohoda pOS table-->
                <saldo>{balance}</saldo>
                <xsl:choose>
                    <xsl:when test="$substring_code = $standard_account_code">

                        <stdUcet>code:{$substring_code}</stdUcet>
                        <typUctuK>{$standard_account_type}</typUctuK>
                        <druhUctuK>{$standard_account_kind}</druhUctuK>
                    </xsl:when>
                    <xsl:otherwise>
                        <typUctuK>typUctu.vnitropodnikovy</typUctuK>
                        <druhUctuK>druhUctu.aktivni</druhUctuK>
                    </xsl:otherwise>
                </xsl:choose>
            </ucet>
        </xsl:if>
    </xsl:template>
    <xsl:template match="lst:itemAccount">
        <ucet>
            <xsl:variable name="code" select="@code"/>
            <xsl:variable name="substring_code" select="substring($code, 0, 4)"/>
            <xsl:variable name="accountFlexi"
                select="document($standard-account_flexi)/winstrom/ucetni-osnova[kod = substring($code, 0, 4)]"/>
            <xsl:variable name="standard_account_code" select="$accountFlexi/kod"/>
            <xsl:variable name="standard_account_type" select="$accountFlexi/typUctuK"/>
            <xsl:variable name="standard_account_kind" select="$accountFlexi/druhUctuK"/>
            <xsl:variable name="existing_id" select="$accountFlexi/id"/>
            <xsl:choose>
                <xsl:when test="$existing_id">
                    <id>{$existing_id}</id>
                </xsl:when>
                <xsl:otherwise>
                    <id>{gi:generateId(@id, $year, true(), false())}</id>
                </xsl:otherwise>
            </xsl:choose>
            <kod>{$code}</kod>
            <nazev>{@name}</nazev>
            <danovy>false</danovy>
            <!-- TODO -->
            <saldo>false</saldo>
            <!-- TODO -->
            <xsl:choose>
                <xsl:when test="$substring_code = $standard_account_code">
                    <stdUcet>{$substring_code}</stdUcet>
                    <typUctuK>{$standard_account_type}</typUctuK>
                    <druhUctuK>{$standard_account_kind}</druhUctuK>
                </xsl:when>
                <xsl:otherwise>
                    <typUctuK>typUctu.vnitropodnikovy</typUctuK>
                    <druhUctuK>druhUctu.aktivni</druhUctuK>
                </xsl:otherwise>
            </xsl:choose>
        </ucet>
    </xsl:template>
</xsl:stylesheet>
