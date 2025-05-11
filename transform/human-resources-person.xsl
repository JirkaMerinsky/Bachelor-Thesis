<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>
    <xsl:template match="item">
        <osoba>
            <xsl:choose>
                <xsl:when test="Osobní_číslo">
                    <osbCis>
                        <xsl:value-of select="Osobní_číslo"/>
                    </osbCis>
                </xsl:when>
                <xsl:otherwise>
                    <osbCis>
                        <xsl:value-of select="concat('ChybíOČ',Id)"/>
                    </osbCis>
                </xsl:otherwise>
            </xsl:choose>
            <id><xsl:value-of select="concat('ext:POHODA:', Id, '-', $year)"/></id>
            <titul>
                <xsl:value-of select="titul"/>
            </titul>
            <jmeno>
                <xsl:value-of select="Jméno"/>
            </jmeno>
            <prijmeni>
                <xsl:value-of select="Příjmení"/>
            </prijmeni>
            <prijmeniRod>
                <xsl:value-of select="Rozená"/>
            </prijmeniRod>
            <funkce>
                <xsl:value-of select="Pracovní_pozice"/>
            </funkce>
            <titul>
                <xsl:value-of select="Titul"/>
            </titul>
            <rodStavK>
                <xsl:call-template name="rodStavTemplate"/>
            </rodStavK>
            <pohlaviK>
                <xsl:choose>
                    <xsl:when test="Pohlaví = '1'">pohlavi.muz</xsl:when>
                    <xsl:when test="Pohlaví = '2'">pohlavi.zena</xsl:when>
                </xsl:choose>
            </pohlaviK>
            <datNaroz>
                <xsl:value-of select="Datnar"/>
            </datNaroz>
            <rodCis>
                <xsl:value-of select="Rodné_číslo"/>
            </rodCis>
            <zdravPoj>
                <xsl:call-template name="pojistovnyTemplate"/>
            </zdravPoj>
            <ucastnikDuchSpor>
                <xsl:choose>
                    <xsl:when test="Penzspolečnost=''">false</xsl:when>
                    <xsl:otherwise>true</xsl:otherwise>
                </xsl:choose>
            </ucastnikDuchSpor>
            <mistoNaroz>
                <xsl:value-of select="Místo_nar"/>
            </mistoNaroz>
            <ulice>
                <xsl:value-of select="Ulice"/>
            </ulice>
            <cisDomu>
                <xsl:value-of select="Číslo_popisné"/>
            </cisDomu>
            <psc>
                <xsl:value-of select="PSČ"/>
            </psc>
            <mesto>
                <xsl:value-of select="Obec"/>
            </mesto>
            <email>
                <xsl:value-of select="Email"/>
            </email>
            <telefon>
                <xsl:value-of select="Telefon"/>
            </telefon>
            <xsl:choose>
                <xsl:when test="Výplata = '1'">
                    <zpusPlatbyK>zpusobPlatby.ucet</zpusPlatbyK>
                </xsl:when>
                <xsl:when test="Výplata = '0'">
                    <zpusPlatbyK>zpusobPlatby.pokladna</zpusPlatbyK>
                </xsl:when>
            </xsl:choose>
            <student>
                <xsl:choose>
                    <xsl:when test="Student = '1'">true</xsl:when>
                    <xsl:when test="Student = '0'">false</xsl:when>
                </xsl:choose>
            </student>
            <xsl:if test="Stát">
                <statObcan>
                    <xsl:if test="Stát">code:<xsl:value-of select="Stát"/>
                    </xsl:if>
                </statObcan>
            </xsl:if>
            <poznam>
                <xsl:value-of select="Poznámka"/>
            </poznam>
            <!--                    úprava kvůli vitadio-->
            <stredisko>
                <xsl:if test="Středisko">
                    <xsl:value-of select="concat('code:', upper-case(Středisko))"/>
                </xsl:if>
            </stredisko>
            <pracovniPomery>
                <pracovni-pomer>
                    <kodELDP>
                        <xsl:value-of select="Typ_ELDP"/>
                    </kodELDP>
                    <zacatek>
                        <xsl:value-of select="Zač_pracpoměru"/>
                    </zacatek>
                    <platiOd>
                        <xsl:value-of select="Zač_pracpoměru"/>
                    </platiOd>
                    <platiDo>
                        <xsl:value-of select="Dat_odchodu"/>
                    </platiDo>
                    <xsl:choose>
                        <xsl:when test="Druh_mzdy = '1'">
                            <typMzdyK>typMzdy.mesicni</typMzdyK>
                            <mesicniMzda>
                                <xsl:value-of select="substring-before(Sazba, ',')"/>
                            </mesicniMzda>
                        </xsl:when>
                        <xsl:when test="Druh_mzdy='2'">
                            <typMzdyK>typMzdy.hodinova</typMzdyK>
                            <hodinovaMzda>
                                <xsl:value-of select="substring-before(Sazba, ',')"/>
                            </hodinovaMzda>
                        </xsl:when>
                        <xsl:when test="Druh_mzdy='3'">
                            <typMzdyK>typMzdy.hodinova</typMzdyK>
                        </xsl:when>
                    </xsl:choose>
                    <staleMzdoveSlozky>
                        <stala-mzdova-slozka>
                            <kod>
                                <xsl:call-template name="druhMzdyAbra"/>
                            </kod>
                            <nazev>
                                <xsl:call-template name="druhMzdyAbra"/>
                            </nazev>
                            <zaklMzd>
                                <xsl:value-of select="substring-before(Sazba, ',')"/>
                            </zaklMzd>
                            <typSlozkyK showAs="Složku zadá uživatel">typSlozky.vstup</typSlozkyK>
                            <skupSlozkyK showAs="Základní mzda">skupinaSlozky.zakladMzda</skupSlozkyK>
                            <cisMzdSloz>
                                <xsl:call-template name="druhMzdyAbra"/>
                            </cisMzdSloz>
                            <pracPom>
                                <xsl:call-template name="zmenaPracPom">
                                    <xsl:with-param name="inputPracPom" select="Druh_pracpoměru"/>
                                </xsl:call-template>
                            </pracPom>
                            <castkaHod>
                                <xsl:choose>
                                    <xsl:when test="Druh_mzdy='Hodinová'">
                                        <xsl:value-of select="substring-before(Sazba, ',')"/>
                                    </xsl:when>
                                    <xsl:otherwise>0</xsl:otherwise>
                                </xsl:choose>
                            </castkaHod>
                        </stala-mzdova-slozka>
                    </staleMzdoveSlozky>
                    <uvazHodDenne>
                        <xsl:value-of select="replace(Úvazek,',','.')"/>
                    </uvazHodDenne>
                    <kod>
                        <xsl:call-template name="zmenaPracPom">
                            <xsl:with-param name="inputPracPom" select="Druh_pracpoměru"/>
                        </xsl:call-template>
                    </kod>
                    <typPracPom>
                        <xsl:call-template name="zmenaPracPom">
                            <xsl:with-param name="inputPracPom" select="Druh_pracpoměru"/>
                        </xsl:call-template>
                    </typPracPom>
                    <pracPomHlav>
                        <xsl:call-template name="zmenaPracPom">
                            <xsl:with-param name="inputPracPom" select="Druh_pracpoměru"/>
                        </xsl:call-template>
                    </pracPomHlav>
                    <duvodUkonceniCsszK>
                        <xsl:choose>
                            <xsl:when test="Zp_ukončení='1'">csszDuvodUkonceni.02</xsl:when>
                            <xsl:when test="Zp_ukončení='11'">csszDuvodUkonceni.03</xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                    </duvodUkonceniCsszK>
                    <xsl:choose>
                        <xsl:when test="Odstupné='4'">
                            <narokOdstupne>true</narokOdstupne>
                            <odstupnePlnaVyse>true</odstupnePlnaVyse>
                            <odstupneNasobek>2</odstupneNasobek>
                        </xsl:when>
                        <xsl:when test="Odstupné='0'">
                            <narokOdstupne>false</narokOdstupne>
                        </xsl:when>
                    </xsl:choose>
                    <dovoleneRocne>
                        <xsl:value-of select="replace(Zákl_výměra_dov_t, ',', '.')"/>
                    </dovoleneRocne>
                    <dovoleneRocneHod>
                        <xsl:value-of select="replace(Zákl_výměra_dov_t, ',', '.')"/>
                    </dovoleneRocneHod>
                    <aktivniOd>
                        <xsl:value-of select="Zač_pracpoměru"/>
                    </aktivniOd>
<!--                    úprava kvůli vitadio-->
<!--                    <praceProStrediska>-->
<!--                        <prace>-->
<!--                            <stredisko>-->
<!--                                <xsl:call-template name="prekladStrediska"/>-->
<!--                            </stredisko>-->
<!--                        </prace>-->
<!--                    </praceProStrediska>-->

                </pracovni-pomer>
            </pracovniPomery>
            <xsl:if test="Číslo_účtuIBAN">
                <bankovniSpojeni>
                    <mzdy-bankovni-spojeni>
                        <buc>
                            <xsl:value-of select="Číslo_účtuIBAN"/>
                        </buc>
                        <xsl:if test="Kód_bankySWIFT">
                            <smerKod>code:<xsl:value-of select="Kód_bankySWIFT"/>
                            </smerKod>
                        </xsl:if>
                    </mzdy-bankovni-spojeni>
                </bankovniSpojeni>
            </xsl:if>
        </osoba>
    </xsl:template>
    <xsl:template name="changeDateFormat">
        <xsl:param name="inputDate"/>
        <xsl:variable name="den" select="substring-before($inputDate, '.')"/>
        <xsl:variable name="mesic"
                      select="substring-before(substring-after($inputDate, '.'), '.')"/>
        <xsl:variable name="rok"
                      select="substring(substring-before($inputDate, ' '), string-length(substring-before($inputDate, ' ')) - 3) "/>
        <xsl:value-of
          select="concat($rok,'-', $mesic,'-', $den)"/>
    </xsl:template>
    <xsl:template name="zmenaPracPom">
        <xsl:param name="inputPracPom"/>
        <!--        Přiřazení jednotlivých typů pracovních poměrů z Pohody do Abry-->
        <xsl:choose>
            <xsl:when test="$inputPracPom &lt; 3 or $inputPracPom = 50 or $inputPracPom = 51 or $inputPracPom = 52
            or $inputPracPom = 100 or $inputPracPom = 101 or $inputPracPom = 102">code:1-STANDARD</xsl:when>
            <xsl:when test="$inputPracPom = 3 or $inputPracPom = 6">code:3-DPČ</xsl:when>
            <xsl:when test="$inputPracPom &gt;= 53 and $inputPracPom &lt;= 60">code:3-DPČ</xsl:when>
            <xsl:when test="$inputPracPom &gt;107">code:2-DPP</xsl:when>
            <xsl:when test="$inputPracPom = 8">code:8-ČLEN DRUŽSTVA</xsl:when>
            <xsl:when test="$inputPracPom = 4">code:DOBROVOLNÝ PRACOVNÍK</xsl:when>
            <xsl:when test="$inputPracPom=107">code:4-SPOL.,JEDN.,ČL.DR.</xsl:when>
            <xsl:when test="$inputPracPom =105">code:5-STATUTÁRNÍ ORGÁN</xsl:when>
        </xsl:choose>
    </xsl:template>
<!--    <xsl:template name="prekladStrediska">-->
<!--        <xsl:choose>-->
<!--            <xsl:when test="Středisko='' or not(Středisko)">code:C</xsl:when>-->
<!--            <xsl:otherwise>code:<xsl:value-of select="Středisko"/>-->
<!--            </xsl:otherwise>-->
<!--        </xsl:choose>-->
<!--    </xsl:template>-->
    <xsl:template name="druhMzdyAbra">
        <xsl:choose>
            <xsl:when test="Druh_mzdy='1'">code:MĚSÍČNÍ MZDA</xsl:when>
            <xsl:when test="Druh_mzdy='2'">code:HODINOVÁ MZDA</xsl:when>
            <xsl:when test="Druh_mzdy='3'">code:ÚKOLOVÁ MZDA</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="pojistovnyTemplate">
        <xsl:choose>
            <!--                Všeobecná zdravotní pojišťovna ČR-->
            <xsl:when test="RefPoj='1'">code:111</xsl:when>
            <!--                Vojenská zdravotní pojišťovna ČR-->
            <xsl:when test="RefPoj='2'">code:201</xsl:when>
            <!--                Česká průmyslová zdravotní pojišťovna-->
            <xsl:when test="RefPoj='3'">code:205</xsl:when>
            <!--                Oborová zdravotní pojišťovna bank, pojišťoven a stavebnictví-->
            <xsl:when test="RefPoj='4'">code:207</xsl:when>
            <!--                Zaměstnanecká pojišťovna Škoda-->
            <xsl:when test="RefPoj='5'">code:209</xsl:when>
            <!--                Zdravotní pojišťovna ministerstva vnitra ČR-->
            <xsl:when test="RefPoj='6'">code:211</xsl:when>
            <!--                Revírní bratrská pokladna, zdravotní pojišťovna-->
            <xsl:when test="RefPoj='7'">code:213</xsl:when>
            <!--                Samoplátce-->
            <xsl:when test="RefPoj='11'">code:SAMOPLÁTCE</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="rodStavTemplate">
        <xsl:choose>
            <xsl:when test="Rod_stav = 1 or Rod_stav = 11">rodStav.svobodny</xsl:when>
            <xsl:when test="Rod_stav = 2 or Rod_stav = 12">rodStav.vdana_zenaty</xsl:when>
            <xsl:when test="Rod_stav = 3 or Rod_stav = 13">rodStav.rozvedeny</xsl:when>
            <xsl:when test="Rod_stav = 5 or Rod_stav = 15">rodStav.vdovec</xsl:when>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>