<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8" />
    
    <xsl:template match="/*">
        <xsl:copy>
            <xsl:apply-templates select="@*" />
            <xsl:apply-templates>
                <xsl:sort select="name()" />
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>