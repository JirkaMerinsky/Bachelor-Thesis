<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rsp="http://www.stormware.cz/schema/version_2/response.xsd">

    <xsl:output method="xml"/>
    <xsl:param name="folderPath"/>
    <xsl:param name="fileName"/>

    <xsl:template match="/">
        <xsl:copy>
            <rsp:responsePack version="2.0">
                <rsp:responsePackItem version="2.0" id="li1" state="ok">
                    <xsl:variable name="listName"
                                  select="document(concat($folderPath, $fileName, '_1.xml'))/*/*/*/name()"/>
                    <xsl:element name="{$listName}">
                        <xsl:for-each
                          select="collection(concat($folderPath, '?select=', $fileName,'_*;recurse=yes'))/*/*/*/node()">
                            <xsl:apply-templates mode="copy" select="."/>
                        </xsl:for-each>
                    </xsl:element>
                </rsp:responsePackItem>
            </rsp:responsePack>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="node()|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates mode="copy" select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*"/>

</xsl:stylesheet>