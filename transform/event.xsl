<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="item">
        <udalost>
            <id>{gi:generateId(Id, $year, true(), false())}</id>
            <predmet>{Nazev}</predmet>
            <popis>{Akce}</popis>
            <firma evidencePath="adresar">ext:POHODA:{CompanyId}</firma>
            <typAkt evidencePath="typ-aktivity">code:UDÁLOST</typAkt>
            <zodpPrac evidencePath="uzivatel">code:zstuchlik</zodpPrac>
            <zahajeni>{Datumvytvoreni}</zahajeni>
            <lastUpdate>{Datumulozeni}</lastUpdate>
            <dokonceni>{Datumdokonceni}</dokonceni>
            <termin>{Datumuzavreni}</termin>
            <!--  Priorita
                  Kritická - priorita.kriticka
                  Vysoká - priorita.vysoka
                  Střední - priorita.stredni
                  Nízká - priorita.nizka
                  Velmi nízká - priorita.velmiNizka  -->
            <prioritaK showAs="Střední">priorita.stredni</prioritaK>
            <!--  Stav události
                  Nová - stavUdal.nove
                  Rozpracováno - stavUdal.rozprac
                  Hotovo - stavUdal.hotovo
                  Zamítnuto - stavUdal.zamitnuto  -->
            <stavUdalK showAs="Nová">

                <xsl:variable name="stateMap" as="map(xs:string, xs:string)">
                    <xsl:map>
                        <xsl:map-entry key="''" select="stavUdal.nove"/>
                        <xsl:map-entry key="rozprac" select="stavUdal.rozprac"/>
                        <xsl:map-entry key="hotovo" select="stavUdal.hotovo"/>
                        <xsl:map-entry key="zamitnuto" select="stavUdal.zamitnuto"/>
                    </xsl:map>
                </xsl:variable>
                <xsl:sequence select="map:get($stateMap, Stav)"/>
            </stavUdalK>

        </udalost>
    </xsl:template>

</xsl:stylesheet>
