<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:json="http://json.org/"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:bnk="http://www.stormware.cz/schema/version_2/bank.xsd"
                xmlns:f="http://www.dcos.cz/flexi-migration/functions">

    <xsl:import href="general/variables.xsl"/>
    <xsl:import href="general/functions.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="bank-account_flexi"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="journal_pohoda"/>
    <xsl:param name="year"/>
    <xsl:param name="lock" select="'open'"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <!--    TODO: !!! ZKONTROLOVAT ZE MAME VSUDE VAR SYMBOL PRO PAROVANI PLATEB MEZI AGENDAMI A BANKOU !!!-->
    <xsl:template match="lst:bank">
        <!--        NEMIGROVAT POCATECNI STAVY, jsou MIGROVANY jako samostatna agenda-->
        <xsl:if test="not(starts-with(bnk:bankHeader/bnk:text,'Počáteční'))">

            <!--BANK DETAIL = obsahuje vice polozek-->
            <xsl:if test="count(bnk:bankDetail/bnk:bankItem) > 1">
                <xsl:for-each select="bnk:bankDetail/bnk:bankItem">

                    <banka json:force-array='true'>
                        <xsl:apply-templates select="../../bnk:bankHeader" mode="items">
                            <xsl:with-param name="item" select="."/>
                            <xsl:with-param name="index" select="position()"/>
                        </xsl:apply-templates>
                        <xsl:apply-templates select="../../bnk:bankSummary" mode="items">
                            <xsl:with-param name="item" select="."/>
                            <xsl:with-param name="index" select="position()"/>
                        </xsl:apply-templates>
                    </banka>
                </xsl:for-each>
            </xsl:if>
            <!--            NO BANK DETAIL = bez polozek nebo s jednou polozkou-->
            <xsl:if test="not(bnk:bankDetail) or count(bnk:bankDetail/bnk:bankItem) = 1">
                <banka json:force-array='true'>
                    <xsl:apply-templates select="bnk:bankHeader"/>
                    <xsl:apply-templates select="bnk:bankSummary"/>
                </banka>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <xsl:template match="bnk:bankHeader">
        <id><xsl:value-of select="concat('ext:POHODA:', bnk:id, '-', $year)"/>
        </id>
        <zamekK>
            <xsl:choose>
                <xsl:when test="$lock = 'open'">zamek.otevreno</xsl:when>
                <xsl:when test="$lock = 'viewable'">zamek.prohlednuto</xsl:when>
                <xsl:when test="$lock = 'halfLocked'">zamek.polozamceno</xsl:when>
                <xsl:when test="$lock = 'locked'">zamek.zamceno</xsl:when>
            </xsl:choose>
        </zamekK>
        <!--Standardni pohyb-->
        <typDokl>code:STANDARD</typDokl>
        <!--Bankovni ucet -->
        <banka>code:<xsl:value-of select="bnk:account/typ:ids"/>
        </banka>
        <!--MANDATORY field ?? -->
        <cisDosle>
            <xsl:value-of select="bnk:number"/>
        </cisDosle>

        <!--        Activity-->
        <xsl:if test="bnk:activity">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(bnk:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>

        <xsl:if test="bnk:statementNumber/bnk:statementNumber">
            <cisSouhrnne>
                <xsl:value-of select="bnk:statementNumber/bnk:statementNumber"/>
            </cisSouhrnne>
        </xsl:if>

        <xsl:if test="bnk:symConst">
            <konSym>code:<xsl:value-of select="bnk:symConst"/>
            </konSym>
        </xsl:if>

        <!--Stredisko-->
        <xsl:if test="bnk:centre">
            <stredisko>code:<xsl:value-of select="upper-case(bnk:centre/typ:ids)"/>
            </stredisko>
        </xsl:if>

        <varSym>
            <xsl:value-of select="bnk:symVar"/>
        </varSym>
        <!--        Items not supported for bank agenda -->
        <bezPolozek>true</bezPolozek>


        <datVyst>
            <xsl:value-of select="bnk:dateStatement"/>
        </datVyst>
        <duzpPuv>
            <xsl:value-of select="bnk:datePayment"/>
        </duzpPuv>
        <datUcto>
            <xsl:value-of select="bnk:datePayment"/>
        </datUcto>
        <datSazbyDph>
            <xsl:value-of select="bnk:datePayment"/>
        </datSazbyDph>

        <popis>
            <xsl:value-of select="f:textSubstring(bnk:text, 255)"/>
        </popis>
        <poznam>
            <xsl:value-of select="bnk:note"/>
        </poznam>

        <xsl:apply-templates select="bnk:accounting"/>
        <xsl:apply-templates select="bnk:partnerIdentity"/>

        <!--        Vat rates deduced from prices-->
        <xsl:variable name="vatRates">
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:priceLowVAT > 0">12</xsl:if>
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
        </xsl:variable>
        <!--        Choose if expense or income-->
        <xsl:variable name="agendaType">
            <xsl:choose>
                <xsl:when test="bnk:bankType = 'receipt'">PRIJEM</xsl:when>
                <xsl:when test="bnk:bankType = 'expense'">VYDEJ</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!--        Call template to fill the account numbers for overall invoice-->
        <xsl:call-template name="createAccountingForSummary">
            <xsl:with-param name="accountingId" select="concat('ext:POHODA:', bnk:accounting/typ:id, '-', $year)"/>
            <xsl:with-param name="vatRates" select="$vatRates"/>
            <xsl:with-param name="documentNumber" select="bnk:number"/>
            <xsl:with-param name="documentId" select="bnk:id"/>
            <xsl:with-param name="agendaType" select="$agendaType"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="bnk:bankHeader" mode="items">
        <xsl:param name="item"/>
        <xsl:param name="index"/>

        <id><xsl:value-of select="concat('ext:POHODA:', bnk:id, '-', $year)"/>
        </id>
        <zamekK>
            <xsl:choose>
                <xsl:when test="$lock = 'open'">zamek.otevreno</xsl:when>
                <xsl:when test="$lock = 'viewable'">zamek.prohlednuto</xsl:when>
                <xsl:when test="$lock = 'halfLocked'">zamek.polozamceno</xsl:when>
                <xsl:when test="$lock = 'locked'">zamek.zamceno</xsl:when>
            </xsl:choose>
        </zamekK>
        <!--Standardni pohyb-->
        <typDokl>code:STANDARD</typDokl>
        <!--Bankovni ucet -->
        <banka>code:<xsl:value-of select="bnk:account/typ:ids"/>
        </banka>
        <!--MANDATORY field ?? -->
        <cisDosle>
            <xsl:value-of select="bnk:number"/>
        </cisDosle>

        <!--        Activity-->
        <xsl:if test="bnk:activity">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(bnk:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>

        <xsl:if test="bnk:statementNumber/bnk:statementNumber">
            <cisSouhrnne>
                <xsl:value-of select="bnk:statementNumber/bnk:statementNumber"/>
            </cisSouhrnne>
        </xsl:if>

        <xsl:if test="bnk:symConst">
            <konSym>code:<xsl:value-of select="bnk:symConst"/>
            </konSym>
        </xsl:if>

        <xsl:apply-templates select="bnk:activity"/>

        <lastUpdate>
            <xsl:value-of select="bnk:date"/>
        </lastUpdate>
        <varSym>
            <xsl:value-of select="bnk:symVar"/>
        </varSym>
        <!--        Items not supported for bank agenda -->
        <bezPolozek>true</bezPolozek>
        <!-- TODO: no idea, wtf? -->
        <datVyst>
            <xsl:value-of select="bnk:dateStatement"/>
        </datVyst>
        <duzpPuv>
            <xsl:value-of select="bnk:datePayment"/>
        </duzpPuv>
        <datUcto>
            <xsl:value-of select="bnk:datePayment"/>
        </datUcto>
        <datSazbyDph>
            <xsl:value-of select="bnk:datePayment"/>
        </datSazbyDph>

        <popis>
            <xsl:value-of select="f:textSubstring($item/bnk:text, 255)"/>
        </popis>
        <poznam>
            <xsl:value-of select="bnk:note"/>
        </poznam>

        <xsl:if test="$item/bnk:accounting">
            <xsl:apply-templates select="bnk:accounting" mode="items">
                <xsl:with-param name="item" select="$item"/>
            </xsl:apply-templates>
        </xsl:if>

        <xsl:apply-templates select="bnk:partnerIdentity"/>

        <!--        Vat rates deduced from prices-->
        <xsl:variable name="vatRates">
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:priceLowVAT > 0">12</xsl:if>
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
            <xsl:if test="../bnk:bankSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
        </xsl:variable>
        <!--        Choose if expense or income-->
        <xsl:variable name="agendaType">
            <xsl:choose>
                <xsl:when test="bnk:bankType = 'receipt'">PRIJEM</xsl:when>
                <xsl:when test="bnk:bankType = 'expense'">VYDEJ</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!--            Call template to assing account values from JOURNAL-->
        <xsl:call-template name="createAccountingForItem">
            <xsl:with-param name="documentNumber" select="bnk:number"/>
            <xsl:with-param name="documentId" select="bnk:id"/>
            <xsl:with-param name="documentItem" select="$item"/>
            <xsl:with-param name="agendaType">
                <xsl:value-of select="$agendaType"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="bnk:accounting">
        <xsl:if test="typ:id and not(typ:accountingType = 'withoutAccounting')">
            <!--            Predkontace -> import at first to Abra, to be able to reference via code afterward-->
            <xsl:if test="typ:ids != 'Bez' and typ:ids != 'Ručně'">
                <typUcOp>
                    <xsl:value-of select="concat('ext:POHODA:', typ:id, '-', $year)"/>
                </typUcOp>
            </xsl:if>

            <xsl:if test="../bnk:paymentAccount/typ:accountNo">
                <buc>
                    <xsl:value-of select="../bnk:paymentAccount/typ:accountNo"/>
                </buc>
                <smerKod>code:<xsl:value-of select="../bnk:paymentAccount/typ:bankCode"/>
                </smerKod>
            </xsl:if>

        </xsl:if>
    </xsl:template>

    <xsl:template match="bnk:accounting" mode="items">
        <xsl:param name="item"/>
        <xsl:if test="typ:id and not(typ:accountingType = 'withoutAccounting')">
            <!--            Predkontace -> import at first to Abra, to be able to reference via code afterward-->
            <xsl:if test="typ:ids != 'Bez' and typ:ids != 'Ručně'">
                <typUcOp>
                    <xsl:value-of select="concat('ext:POHODA:', typ:id, '-', $year)"/>
                </typUcOp>
            </xsl:if>

            <xsl:if test="../bnk:paymentAccount/typ:accountNo">
                <buc>
                    <xsl:value-of select="../bnk:paymentAccount/typ:accountNo"/>
                </buc>
                <smerKod>code:<xsl:value-of select="../bnk:paymentAccount/typ:bankCode"/>
                </smerKod>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="bnk:partnerIdentity">
        <xsl:choose>
            <xsl:when test="typ:id">
                <firma><xsl:value-of select="concat('ext:POHODA:', typ:id, '-', $year)"/>
                </firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="typ:address">
                    <nazFirmy>
                        <xsl:value-of select="typ:address/typ:company"/>
                    </nazFirmy>
                    <ulice>
                        <xsl:value-of select="typ:address/typ:street"/>
                    </ulice>
                    <mesto>
                        <xsl:value-of select="typ:address/typ:city"/>
                    </mesto>
                    <psc>
                        <xsl:value-of select="typ:address/typ:zip"/>
                    </psc>
                    <ic>
                        <xsl:value-of select="typ:address/typ:ico"/>
                    </ic>
                    <dic>
                        <xsl:value-of select="typ:address/typ:dic"/>
                    </dic>
                    <xsl:choose>
                        <xsl:when test="typ:shipToAddress/typ:city">
                            <postovniShodna>false</postovniShodna>
                            <faNazev>
                                <xsl:value-of select="typ:shipToAddress/typ:company"/>
                            </faNazev>
                            <faNazev2>
                                <xsl:value-of select="typ:shipToAddress/typ:name"/>
                            </faNazev2>
                            <faUlice>
                                <xsl:value-of select="typ:shipToAddress/typ:street"/>
                            </faUlice>
                            <faMesto>
                                <xsl:value-of select="typ:shipToAddress/typ:city"/>
                            </faMesto>
                            <faPsc>
                                <xsl:value-of select="typ:shipToAddress/typ:zip"/>
                            </faPsc>
                        </xsl:when>
                        <xsl:otherwise>
                            <postovniShodna>true</postovniShodna>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="bnk:bankSummary">
        <!--        TODO predelat nejak rozumne na template-->
        <xsl:if test="bnk:foreignCurrency">
            <mena>code:<xsl:value-of select="bnk:foreignCurrency/typ:currency/typ:ids"/>
            </mena>
            <kurz>
                <xsl:value-of select="bnk:foreignCurrency/typ:rate"/>
            </kurz>
            <sumCelkemMen>
                <xsl:value-of select="bnk:foreignCurrency/typ:priceSum"/>
            </sumCelkemMen>
        </xsl:if>

        <xsl:choose>
            <xsl:when
              test="../bnk:bankHeader/bnk:bankType = 'receipt' and  xs:decimal(bnk:homeCurrency/typ:priceNone)  lt 0  ">

                <xsl:message>ACC_PROBLEM:Záporný příjem v bance. Mění se na výdej. Mouhou být problémy se zůstatky na
                    účtech. Id dokladu:<xsl:value-of select="../bnk:bankHeader/bnk:id"/>. Suma:<xsl:value-of
                      select="bnk:homeCurrency/typ:priceNone"/>
                </xsl:message>

                <typPohybuK>typPohybu.vydej</typPohybuK>
                <sumOsv>
                    <xsl:value-of select="bnk:homeCurrency/typ:priceNone * (-1)"/>
                </sumOsv>
            </xsl:when>

            <xsl:when
              test="../bnk:bankHeader/bnk:bankType = 'expense' and  xs:decimal(bnk:homeCurrency/typ:priceNone)  lt 0  ">

                <xsl:message>ACC_PROBLEM:Záporný výdej v bance. Mění se na příjem. Mouhou být problémy se zůstatky na
                    účtech. Id dokladu:<xsl:value-of select="../bnk:bankHeader/bnk:id"/>. Suma:<xsl:value-of
                      select="bnk:homeCurrency/typ:priceNone"/>
                </xsl:message>

                <typPohybuK>typPohybu.prijem</typPohybuK>
                <sumOsv>
                    <xsl:value-of select="bnk:homeCurrency/typ:priceNone * (-1)"/>
                </sumOsv>
            </xsl:when>

            <xsl:otherwise>
                <typPohybuK>
                    <xsl:choose>
                        <xsl:when test="../bnk:bankHeader/bnk:bankType = 'receipt'">typPohybu.prijem</xsl:when>
                        <xsl:when test="../bnk:bankHeader/bnk:bankType = 'expense'">typPohybu.vydej</xsl:when>
                    </xsl:choose>
                </typPohybuK>
                <sumOsv>
                    <xsl:value-of select="bnk:homeCurrency/typ:priceNone"/>
                </sumOsv>
            </xsl:otherwise>
        </xsl:choose>

        <!--        <sumZklSniz>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:priceLow"/>-->
        <!--        </sumZklSniz>-->
        <!--        <sumZklSniz2>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:price3"/>-->
        <!--        </sumZklSniz2>-->
        <!--        <sumZklZakl>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:priceHigh"/>-->
        <!--        </sumZklZakl>-->

        <!--        <sumDphSniz>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:priceLowVAT"/>-->
        <!--        </sumDphSniz>-->
        <!--        <sumDphSniz2>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:price3VAT"/>-->
        <!--        </sumDphSniz2>-->
        <!--        <sumDphZakl>-->
        <!--            <xsl:value-of select="bnk:homeCurrency/typ:priceHighVAT"/>-->
        <!--        </sumDphZakl>-->

        <sumCelkSniz>
            <xsl:value-of select="bnk:homeCurrency/typ:priceLowSum"/>
        </sumCelkSniz>
        <sumCelkSniz2>
            <xsl:value-of select="bnk:homeCurrency/typ:price3Sum"/>
        </sumCelkSniz2>
        <sumCelkZakl>
            <xsl:value-of select="bnk:homeCurrency/typ:priceHighSum"/>
        </sumCelkZakl>
        <szbDphZakl>
            <xsl:value-of select="bnk:homeCurrency/typ:priceHighVAT/@rate"/>
        </szbDphZakl>
        <szbDphSniz>
            <xsl:value-of select="bnk:homeCurrency/typ:priceLowVAT/@rate"/>
        </szbDphSniz>
        <szbDphSniz2>
            <xsl:value-of select="bnk:homeCurrency/typ:price3VAT/@rate"/>
        </szbDphSniz2>

    </xsl:template>

    <xsl:template match="bnk:bankSummary" mode="items">
        <xsl:param name="item"/>
        <!--        TODO predelat nejak rozumne na template-->
        <xsl:if test="$item/bnk:foreignCurrency">
            <mena>code:<xsl:value-of select="bnk:foreignCurrency/typ:currency/typ:ids"/>
            </mena>
            <kurz>
                <xsl:value-of select="bnk:foreignCurrency/typ:rate"/>
            </kurz>
            <sumCelkemMen>
                <xsl:value-of select="$item/bnk:foreignCurrency/bnk:unitPrice"/>
            </sumCelkemMen>
        </xsl:if>

        <xsl:choose>
            <xsl:when
              test="../bnk:bankHeader/bnk:bankType = 'receipt' and  xs:decimal(bnk:homeCurrency/typ:priceNone)  lt 0  ">

                <xsl:message>ACC_PROBLEM:Záporný příjem v bance. Mění se na výdej. Mouhou být problémy se zůstatky na
                    účtech. Id dokladu:<xsl:value-of select="../bnk:bankHeader/bnk:id"/>. Suma:<xsl:value-of
                      select="bnk:homeCurrency/typ:priceNone"/>
                </xsl:message>

                <typPohybuK>typPohybu.vydej</typPohybuK>
                <sumOsv>
                    <xsl:value-of select="bnk:homeCurrency/typ:priceNone * (-1)"/>
                </sumOsv>
            </xsl:when>

            <xsl:when
              test="../bnk:bankHeader/bnk:bankType = 'expense' and  xs:decimal(bnk:homeCurrency/typ:priceNone)  lt 0  ">

                <xsl:message>ACC_PROBLEM:Záporný výdej v bance. Mění se na příjem. Mouhou být problémy se zůstatky na
                    účtech. Id dokladu:<xsl:value-of select="../bnk:bankHeader/bnk:id"/>. Suma:<xsl:value-of
                      select="bnk:homeCurrency/typ:priceNone"/>
                </xsl:message>

                <typPohybuK>typPohybu.prijem</typPohybuK>
                <sumOsv>
                    <xsl:value-of select="bnk:homeCurrency/typ:priceNone * (-1)"/>
                </sumOsv>
            </xsl:when>

            <xsl:otherwise>
                <typPohybuK>
                    <xsl:choose>
                        <xsl:when test="../bnk:bankHeader/bnk:bankType = 'receipt'">typPohybu.prijem</xsl:when>
                        <xsl:when test="../bnk:bankHeader/bnk:bankType = 'expense'">typPohybu.vydej</xsl:when>
                    </xsl:choose>
                </typPohybuK>
                <sumOsv>
                    <xsl:value-of select="$item/bnk:homeCurrency/bnk:unitPrice"/>
                </sumOsv>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--    Template to create accounting detail for agenda (not for item). Fill in accounts -->
    <xsl:template name="createAccountingForSummary">
        <!--        VAT rate of document of the interest in POHODA xml file-->
        <xsl:param name="vatRates"/>
        <!--Number of the document of the interest in xml POHODA file. -->
        <xsl:param name="documentNumber"/>
        <!--IDS of the accounting node ==> references the  "PREDPISY ZAUCTOVANI" in ABRA  -->
        <xsl:param name="accountingId"/>
        <!--        Id of the document of the interest, usually placed in agenda header in POHODA xml file-->
        <xsl:param name="documentId"/>
        <!--        Decide wheteher it is PRIJEM or VYDEJ (prijata nebo vydana faktura popripade jiny typ agendy)-->
        <xsl:param name="agendaType"/>

        <!--        References the row in JOURNAL POHODA. Contains details about account-->
        <xsl:variable name="account"
                      select="document($journal_pohoda)/items/item[evidenceId = 28 and documentId = $documentId and not(starts-with(text, 'DPH'))][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                    Prijem ==>    PRIM UCET = DAL acc-->
                        <primUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </protiUcet>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--             Vydej ==>        PRIM UCET = MD acc -->
                        <primUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </protiUcet>

                    </xsl:otherwise>
                </xsl:choose>
                <!--        References the row in JOURNAL POHODA. Contains details about DPH account-->
                <xsl:variable name="vatAccount"
                              select="document($journal_pohoda)/items/item[evidenceId = 28 and documentId = $documentId and starts-with(text, 'DPH')][1]"/>

                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <!--                         Pro vydej = DAL. Pro prijem = MD -->
                        <xsl:choose>
                            <xsl:when test="$agendaType = 'PRIJEM'">
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                                        </dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '12')">
                                        <dphSnizUcet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                                        </dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                                        </dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                                        </dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '12')">
                                        <dphSnizUcet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                                        </dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                                        </dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:if test="number($vatRates) > 0">
                            <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v účetním
                                deníku
                                pro dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of
                                  select="$documentNumber"/>
                            </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>

                <xsl:variable name="accountAssignment" as="node()*">
                    <xsl:sequence
                      select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=$accountingId]"/>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$accountAssignment">
                        <primUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetPrijem"/>
                        </primUcet>
                        <protiUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetVydej"/>
                        </protiUcet>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:message>ACC_PROBLEM: Záučtovaní dokladu neproběhlo. Nenalezen záznam v předkontacích pro
                            dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of
                              select="$documentNumber"/>. ID předkontace:<xsl:value-of select="$accountingId"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!--    Template to apply the account values for each Item-->
    <xsl:template name="createAccountingForItem">
        <!--Number of the document of the interest in xml POHODA file. -->
        <xsl:param name="documentNumber"/>
        <!--        Id of the document of the interest, usually placed in agenda header in POHODA xml file-->
        <xsl:param name="documentId"/>
        <!--        Item node of the interest-->
        <xsl:param name="documentItem"/>
        <!--        Agenda type = prijem / vydej-->
        <xsl:param name="agendaType"/>

        <xsl:variable name="price">
            <xsl:value-of select="$documentItem/*:homeCurrency/bnk:unitPrice"/>
        </xsl:variable>
        <xsl:variable name="account"
                      select="document($journal_pohoda)/items/item[evidenceId = 28 and documentId = $documentId and not(starts-with(text, 'DPH')) and xs:decimal(amount) = xs:decimal($price)][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                    Prijem ==>    PRIM UCET = DAL acc-->
                        <primUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </protiUcet>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--             Vydej ==>        PRIM UCET = MD acc -->
                        <primUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </protiUcet>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>