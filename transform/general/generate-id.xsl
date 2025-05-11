<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <!--    Function to generate ext:POHODA id with year-->
    <xsl:function name="gi:generateId">
        <xsl:param name="id" as="xs:integer"/>
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="useYear" as="xs:boolean"/>
        <xsl:param name="isItem" as="xs:boolean"/>
        <xsl:sequence
            select="'ext:POHODA:' || 'polozka-'[$isItem] || $id || '-'[$useYear] || $year[$useYear]"
        />
    </xsl:function>
</xsl:stylesheet>
