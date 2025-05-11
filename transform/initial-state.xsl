<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" expand-text="yes"
>

    <xsl:include href="general/document-common.xsl"/>
    <xsl:param name="year"/>

    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="items">
        <winstrom version="1.0" source="Pohoda">
            <!--            <xsl:apply-templates/>-->
            <interni-doklad json:force-array='true'>
                <datVyst>{item[1]/date}</datVyst>

                <popis>pocatecni stavy uctu - -->{$year}</popis>

                <typDokl>code:INT. DOKLAD</typDokl>

                <rada if-not-found="null">code:INTERNÍ DOKLADY</rada>

                <bezPolozek>false</bezPolozek>

                <ucetni>true</ucetni>

                <polozkyIntDokladu removeAll="true">
                    
                    <xsl:apply-templates select="item"/>
                    
                </polozkyIntDokladu>

            </interni-doklad>
        </winstrom>
    </xsl:template>

    <xsl:template match="item">
        <xsl:if test="text = 'Počáteční stav účtu'">

            <interni-doklad-polozka>
                <ucetni>true</ucetni>
                <nazev>{text}</nazev>

                <typPolozkyK>typPolozky.ucetni</typPolozkyK>
                <mnozMj>1</mnozMj>

                <typCenyDphK>typCeny.bezDph</typCenyDphK>

                <!--  VAT rate category
                VAT-exempt - typSzbDph.dphOsv
                Reduced - typSzbDph.dphSniz
                2nd reduced  - typSzbDph.dphSniz2
                Basic - typSzbDph.dphZakl  -->
                <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>

                <szbDph>0</szbDph>

                <zklMdUcet>code:{mdAccount}</zklMdUcet>
                <zklDalUcet>code:{dAccount}</zklDalUcet>

                <kopZklMdUcet>false</kopZklMdUcet>
                <kopZklDalUcet>false</kopZklDalUcet>
                <kopClenDph>false</kopClenDph>

                <sumCelkem>
                    <xsl:value-of select="amount"/>
                </sumCelkem>
            </interni-doklad-polozka>

        </xsl:if>

        <xsl:if test="starts-with(text, 'Převod') ">
            <interni-doklad-polozka>
                <ucetni>true</ucetni>
                <nazev>{text}</nazev>

                <typPolozkyK>typPolozky.ucetni</typPolozkyK>
                <mnozMj>1</mnozMj>

                <typCenyDphK>typCeny.bezDph</typCenyDphK>

                <!--  VAT rate category
                VAT-exempt - typSzbDph.dphOsv
                Reduced - typSzbDph.dphSniz
                2nd reduced  - typSzbDph.dphSniz2
                Basic - typSzbDph.dphZakl  -->
                <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>

                <szbDph>0</szbDph>

                <zklMdUcet>code:{mdAccount}</zklMdUcet>
                <zklDalUcet>code:{dAccount}</zklDalUcet>

                <kopZklMdUcet>false</kopZklMdUcet>
                <kopZklDalUcet>false</kopZklDalUcet>
                <kopClenDph>false</kopClenDph>

                <sumCelkem>{amount}</sumCelkem>
            </interni-doklad-polozka>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>