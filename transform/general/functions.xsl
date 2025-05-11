<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.dcos.cz/flexi-migration/functions" version="2.0">

    <!-- GENERATE UID -->
    <xsl:function name="f:generateUid">
        <xsl:param name="variable_symbol"/>
        <xsl:param name="partner_id"/>
        <xsl:param name="partner_name"/>
        <xsl:param name="sum_total"/>
        <xsl:choose>
            <xsl:when test="$partner_id != ''"> ext:POHODA-UID:<xsl:value-of
                    select="$variable_symbol"/>-<xsl:value-of select="$partner_id"/>-<xsl:value-of
                    select="$sum_total"/>
            </xsl:when>
            <xsl:otherwise> ext:POHODA-UID:<xsl:value-of select="$variable_symbol"/>-<xsl:value-of
                    select="$partner_name"/>-<xsl:value-of select="$sum_total"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!-- Trimms string if necessary -->
    <xsl:function name="f:textSubstring">
        <xsl:param name="string"/>
        <xsl:param name="length"/>
        <xsl:choose>
            <xsl:when test="string-length($string) > $length">
                <xsl:message terminate="no">Trimming string <xsl:value-of select="$string"/>! </xsl:message>
                <xsl:value-of select="substring($string, 0, $length)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


    <!-- Validates date -->
    <xsl:function name="f:validateDate">
        <xsl:param name="date"/>
        <xsl:if test="$date and $date/node() and not($date castable as xs:date)">
            <xsl:message terminate="yes">
                <xsl:value-of select="$date"/> is not a date! </xsl:message>
        </xsl:if>
        <xsl:value-of select="$date"/>

    </xsl:function>


    <!-- Validates number - if it is number and trims it if necessary -->
    <xsl:function name="f:validateAndTrimNumber">
        <xsl:param name="number"/>
        <xsl:param name="length"/>
        <xsl:if test="$number and $number/node() and not(number($number) = number($number))">
            <xsl:message terminate="yes">
                <xsl:value-of select="$number"/> is not a number! </xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($number) > $length">
                <xsl:message terminate="no">Trimming number <xsl:value-of select="$number"/>! </xsl:message>
                <xsl:value-of select="upper-case(substring($number, 0, $length))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
