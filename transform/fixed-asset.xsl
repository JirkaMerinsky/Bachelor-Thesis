<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:json="http://json.org/">

    <xsl:import href="general/functions.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="journal_pohoda"/>


    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <!-- TODO: ADD TO FUNCTIONS -->
    <xsl:template match="Zarazeni|Porizeni">
        <xsl:choose>
            <xsl:when test="contains(., '/')">
                <xsl:analyze-string select="." regex="([0-9]{{1,2}})/([0-9]{{1,2}})/([0-9]{{4}}) (.+)">
                    <xsl:matching-substring>
                        <xsl:value-of select=
                                        "xs:date(concat(number(regex-group(3)), '-', format-number(number(regex-group(1)), '00'), '-',
                                    format-number(number(regex-group(2)), '00') )),'[Y0001]-[M01]-[D01]'"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:sequence select="."></xsl:sequence>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="." regex="([0-9]{{1,2}}).([0-9]{{1,2}}).([0-9]{{4}}) (.+)">
                    <xsl:matching-substring>
                        <xsl:value-of select=
                                        "xs:date(concat(number(regex-group(3)), '-', format-number(number(regex-group(2)), '00'), '-',
                                    format-number(number(regex-group(1)), '00') )),'[Y0001]-[M01]-[D01]'"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:sequence select="."></xsl:sequence>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="item">
        <majetek json:force-array='true'>
            <kod>
                <xsl:value-of select="Cislo"/>
            </kod>
            <nazev>
                <xsl:value-of select="Nazev"/>
            </nazev>
            <poznam>
                <xsl:value-of select="Poznamka"/>
            </poznam>
            <cena>
                <xsl:value-of select="replace(replace(Ucetniporizovacicena , '[^0-9,..]', ''), ',', '.')"/>
            </cena>
            <zustUcet>
                <xsl:value-of select="replace(replace(Ucetnizustatek , '[^0-9,..]', ''), ',', '.')"/>
            </zustUcet>
            <xsl:choose>
                <xsl:when test="Zakazka">
                    <zakazka>code:<xsl:value-of select="Zakazka"/></zakazka>
                </xsl:when>
            </xsl:choose>
            <zustDan>
                <xsl:value-of select="replace(replace(Danovyzustatek , '[^0-9,..]', ''), ',', '.')"/>
            </zustDan>
            <xsl:choose>
                <xsl:when test="Stredisko">
                    <stredisko>code:<xsl:value-of select="Stredisko"/>
                    </stredisko>
                </xsl:when>
                <xsl:otherwise>
                    <stredisko>code:C</stredisko>
                </xsl:otherwise>
            </xsl:choose>

            <datZar>
                <xsl:apply-templates select="Zarazeni"/>
            </datZar>
            <datZacDan>
                <xsl:apply-templates select="Zarazeni"/>
            </datZacDan>
            <datZacUcet>
                <xsl:apply-templates select="Zarazeni"/>
            </datZacUcet>
            <datKoupe>
                <xsl:apply-templates select="Porizeni"/>
            </datKoupe>

            <!--            <xsl:variable name="docId" select="Id"/>-->
            <!--            <xsl:variable name="price" select="Ucetniporizovacicena"/>-->

            <!--            <xsl:variable name="account"-->
            <!--                          select="document($journal_pohoda)/items/item[evidenceId = 5 and documentId = $docId  and xs:decimal(amount) = xs:decimal($price)][1]"/>-->

            <!--            <xsl:choose>-->
            <!--                <xsl:when test="$account and $account != ''">-->

            <!--                    <primarniUcet>code:<xsl:value-of select="$account/mdAccount"/>-->
            <!--                    </primarniUcet>-->
            <!--                    &lt;!&ndash; Protiúč.zař. (objekt) - max. délka: 6 &ndash;&gt;-->
            <!--                    <protiUcetZarazeni>code:<xsl:value-of select="$account/dAccount"/>-->
            <!--                    </protiUcetZarazeni>-->
            <!--                </xsl:when>-->
            <!--                <xsl:otherwise>-->
            <!--                    <xsl:message>ACC_PROBLEM: Záučtovaní majetku neproběhlo. Nenalezen záznam v účetním deníku pro-->
            <!--                        dokument s id <xsl:value-of select="$docId"/>. Název položky:-->
            <!--                        <xsl:value-of select="Nazev"/>-->
            <!--                    </xsl:message>-->
            <!--                </xsl:otherwise>-->
            <!--            </xsl:choose>-->

            <xsl:choose>
                <xsl:when test="RelZpPor = 1">
                    <zpusPor>Koupě</zpusPor>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>

            <!--            TODO vyrazeni-->
            <datUdalVyr></datUdalVyr>

            <!-- TODO: FINISH FOR ALL CASES -->
            <xsl:choose>
                <xsl:when test="RelTpIM = '3' and Danovyzustatek != 0 and Ucetnizustatek != 0">
                    <druhK showAs="Nehmotný dlouhodobý">druhMaj.nehmDl</druhK>
                    <!--                    <typMajetku>code:DLOUHODOBÝ HM.</typMajetku>-->
                </xsl:when>
                <xsl:when test="(RelTpIM != '1' or RelTpIM != '2') and Danovyzustatek != 0 and Ucetnizustatek != 0">
                    <druhK showAs="Hmotný dlouhodobý">druhMaj.hmDl</druhK>
                    <!--                    <typMajetku>code:DLOUHODOBÝ HM.</typMajetku>-->
                </xsl:when>
            </xsl:choose>

            <!--            TODO: make no sense to keep in switch statement, if always true -->
            <typMajetku>code:DLOUHODOBÝ HM.</typMajetku>

            <xsl:choose>
                <xsl:when test="RelTpOdp = 4">
                    <nahrUcetOdpK>nahrUcet.ne</nahrUcetOdpK>
                </xsl:when>
                <xsl:when test="Danovyzustatek = 0 and Ucetnizustatek = 0">
                    <nahrUcetOdpK>nahrUcet.ne</nahrUcetOdpK>
                </xsl:when>
                <xsl:otherwise>
                    <nahrUcetOdpK showAs="Ano">nahrUcet.aPocMes</nahrUcetOdpK>
                </xsl:otherwise>
            </xsl:choose>

            <!--            Urcit odpisovou skupinu a pocet mesicu odpoctu a sazba-->
            <xsl:choose>
                <xsl:when test="Danovyzustatek != 0 or Ucetnizustatek != 0">
                    <xsl:choose>
                        <xsl:when test="Plan = '3'">
                            <predpisUcetOdp>36</predpisUcetOdp>
                        </xsl:when>
                        <xsl:when test="Plan = '5'">
                            <predpisUcetOdp>60</predpisUcetOdp>
                        </xsl:when>
                        <xsl:when test="Plan = '6'">
                            <predpisUcetOdp>72</predpisUcetOdp>
                        </xsl:when>
                        <xsl:when test="Plan = '10'">
                            <predpisUcetOdp>120</predpisUcetOdp>
                        </xsl:when>
                        <xsl:when test="Plan = '20'">
                            <predpisUcetOdp>240</predpisUcetOdp>
                        </xsl:when>
                        <xsl:when test="Plan = '30'">
                            <predpisUcetOdp>360</predpisUcetOdp>
                        </xsl:when>
                        <xsl:otherwise>
                            <predpisUcetOdp>36</predpisUcetOdp>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>


            <xsl:choose>
                <xsl:when test="Danovyzustatek = 0 and Ucetnizustatek = 0">
                    <druhK>druhMaj.neodepis</druhK>
                    <ucetni>false</ucetni>
                </xsl:when>
                <!--                zrychlene opdisy-->
                <xsl:when test="RelTpOdp = '2'">
                    <zpusOdpK>typOdp.zrych</zpusOdpK>
                    <xsl:choose>
                        <xsl:when test="RelSkOdp = '1'">
                            <sazba>code:Z1</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '2'">
                            <sazba>code:Z2</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '3'">
                            <sazba>code:Z3</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '4'">
                            <sazba>code:Z4</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '5'">
                            <sazba>code:Z5N</sazba>
                            <!--                            <predpisUcetOdp>360</predpisUcetOdp>-->
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '11'">
                            <sazba>code:Z1</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '12'">
                            <sazba>code:Z2</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '13'">
                            <sazba>code:Z3</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '14'">
                            <sazba>code:Z4</sazba>
                            <zvysZrychK>zvysZrych.proc10</zvysZrychK>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!--                rovnomerne opdisy-->
                <xsl:when test="RelTpOdp = '1'">
                    <zpusOdpK>typOdp.rovn</zpusOdpK>
                    <xsl:choose>
                        <xsl:when test="RelSkOdp = '1'">
                            <sazba>code:R1</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '2'">
                            <sazba>code:R2</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '3'">
                            <sazba>code:R3</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '4'">
                            <sazba>code:R4</sazba>
                        </xsl:when>
                        <xsl:otherwise>
                            <sazba>code:R1</sazba>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <!--                Bez odpisu-->
                <xsl:when test="RelTpOdp = '4'">
                    <druhK>druhMaj.neodepis</druhK>
                    <ucetni>false</ucetni>
                </xsl:when>
                <!--         Pouze ucetni odpis-->
                <xsl:when test="RelTpOdp = '6'">
                    <!--                    <druhK>druhMaj.nehmDl</druhK>-->
                    <zpusOdpK>typOdp.rovn</zpusOdpK>
                    <xsl:choose>
                        <xsl:when test="RelSkOdp = '1'">
                            <sazba>code:R1</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '2'">
                            <sazba>code:R2</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '3'">
                            <sazba>code:R3</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '4'">
                            <sazba>code:R4</sazba>
                        </xsl:when>
                        <xsl:otherwise>
                            <sazba>code:R1</sazba>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:when>
                <!--         NM software, vyzkum, vyvoj-->
                <xsl:when test="RelTpOdp = '11'">
                    <!--                    <druhK>druhMaj.nehmDl</druhK>-->
                    <zpusOdpK>typOdp.rovn</zpusOdpK>
                    <xsl:choose>
                        <xsl:when test="RelSkOdp = '1'">
                            <sazba>code:R1</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '2'">
                            <sazba>code:R2</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '3'">
                            <sazba>code:R3</sazba>
                        </xsl:when>
                        <xsl:when test="RelSkOdp = '4'">
                            <sazba>code:R4</sazba>
                        </xsl:when>
                        <xsl:otherwise>
                            <sazba>code:R1</sazba>
                        </xsl:otherwise>
                    </xsl:choose>

                </xsl:when>

                <xsl:otherwise>
                    <zpusOdpK>typOdp.rovn</zpusOdpK>
                    <sazba>code:R1</sazba>
                </xsl:otherwise>


            </xsl:choose>
        </majetek>
    </xsl:template>


</xsl:stylesheet>