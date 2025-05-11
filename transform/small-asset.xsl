<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:json="http://json.org/" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="item">
        <majetek json:force-array='true'>
            <id>ext:POHODA:{Id}</id>
            <kod>{Cislo}</kod>
            <nazev>{Nazev}</nazev>
            <poznam>{Poznamka}</poznam>
            <cena>{number(Jedncena * Pocet)}</cena>
            <kusySoubor>{Pocet}</kusySoubor>

            <!--            UCTOVAT zarazeni - zatim davam ze ne - potreba projit -->
            <uctovatZar>false</uctovatZar>
            <xsl:choose>
                <xsl:when test="Stredisko">
                    <stredisko>code:{Stredisko}</stredisko>
                </xsl:when>
                <xsl:otherwise>
                    <stredisko>code:C</stredisko>
                </xsl:otherwise>
            </xsl:choose>
            <datZar>{Datum}</datZar>
            <datKoupe>{Datum}</datKoupe>
            <druhK>druhMaj.drobny</druhK>
            <typMajetku>code:NEODEPISOVANÝ</typMajetku>
            <!-- <nahrUcetOdpK showAs="Ano">nahrUcet.aPocMes</nahrUcetOdpK> -->
        </majetek>
    </xsl:template>
</xsl:stylesheet>