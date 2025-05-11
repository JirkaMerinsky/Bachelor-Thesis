<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:f="http://www.dcos.cz/flexi-migration/functions" exclude-result-prefixes="xs"
    version="3.0">
    <xsl:include href="../functions.xsl"/>
    <xsl:function name="inf:vatMapFunction">
        <xsl:param name="vat-mapping"/>
        <xsl:param name="documentItem"/>
        <xsl:param name="classificationVatCode"/>
        <xsl:for-each select="document($vat-mapping)/items/item">
            <xsl:if test="Pohoda_zkratka = $classificationVatCode">
                <!--                Assign 'clenDph' = radky DPH. Use code reference-->
                <clenDph>
                    <xsl:sequence select="'code:' || f:textSubstring(Flexy_radky_dph_zkratka, 15)"/>
                </clenDph>
                <!--                 Copy the row of the DPH = false-->
                <kopClenDph>false</kopClenDph>

                <!--                Assing 'clenKonVykDph' = radky kontrolniho hlaseni. Use code reference-->
                <xsl:if test="Flexi_radky_khdph_zkratka/node()">
                    <clenKonVykDph>
                        <xsl:sequence
                            select="'code:' || f:textSubstring(Flexi_radky_khdph_zkratka, 15)"/>
                    </clenKonVykDph>
                    <!--                    Copy the row of the KH_DPH = false -->
                    <kopClenKonVykDph>false</kopClenKonVykDph>
                </xsl:if>

                <!--                Assign 'dphPren' = preneseni DPH. Not used in our application now -->
                <xsl:if test="Pdp/node()">
                    <dphPren>
                        <xsl:sequence select="'code:' || Pdp"/>
                    </dphPren>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>
