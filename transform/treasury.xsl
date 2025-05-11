<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:json="http://json.org/"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:vch="http://www.stormware.cz/schema/version_2/voucher.xsd"
                xmlns:f="http://www.dcos.cz/flexi-migration/functions"
                xmlns:dc="http://www.dcos.cz/flexi-migration/document-common">

    <xsl:import href="general/document-common.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="journal_pohoda"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:voucher">
        <xsl:if test="not(starts-with(vch:voucherHeader/vch:text,'Počáteční'))">
            <pokladni-pohyb json:force-array='true'>
                <xsl:apply-templates select="vch:voucherHeader"/>
                <xsl:apply-templates select="vch:voucherDetail"/>
                <xsl:apply-templates select="vch:voucherSummary"/>
            </pokladni-pohyb>
        </xsl:if>
    </xsl:template>

    <xsl:template match="vch:voucherHeader">
        <id>
            <xsl:value-of select="concat('ext:POHODA:', vch:id, '-', $year)"/>
        </id>
        <kod>
            <xsl:value-of select="vch:number/typ:numberRequested"/>
        </kod>

        <zamekK>
            <xsl:choose>
                <xsl:when test="$lock = 'open'">zamek.otevreno</xsl:when>
                <xsl:when test="$lock = 'viewable'">zamek.prohlednuto</xsl:when>
                <xsl:when test="$lock = 'halfLocked'">zamek.polozamceno</xsl:when>
                <xsl:when test="$lock = 'locked'">zamek.zamceno</xsl:when>
            </xsl:choose>
        </zamekK>


        <xsl:if test="vch:number/typ:numberRequested">
            <cisDosle>
                <xsl:choose>
                    <!--                Received invoice shall use original document number -->
                    <xsl:when test="vch:originalDocument">
                        <xsl:value-of select="vch:originalDocument"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--                    If original document number is missing, use variable symbol instead-->
                        <xsl:value-of select="vch:symVar"/>
                    </xsl:otherwise>
                </xsl:choose>
            </cisDosle>
        </xsl:if>
        <xsl:if test="vch:contract">
            <zakazka>code:<xsl:value-of select="upper-case(vch:contract/typ:ids)"/>
            </zakazka>
        </xsl:if>

        <datVyst>
            <xsl:value-of select="vch:date"/>
        </datVyst>

        <xsl:choose>
            <xsl:when test="vch:dateKHDPH">
                <duzpUcto>
                    <xsl:value-of select="vch:dateTax"/>
                </duzpUcto>
                <duzpPuv>
                    <xsl:value-of select="vch:dateKHDPH"/>
                </duzpPuv>
            </xsl:when>
            <xsl:otherwise>
                <duzpUcto>
                    <xsl:value-of select="vch:dateAccounting"/>
                </duzpUcto>
                <duzpPuv>
                    <xsl:value-of select="vch:dateTax"/>
                </duzpPuv>
            </xsl:otherwise>
        </xsl:choose>

        <datSazbyDph>
            <xsl:value-of select="vch:dateTax"/>
        </datSazbyDph>

        <xsl:choose>
            <xsl:when test="vch:symVar">
                <varSym>
                    <xsl:value-of select="f:textSubstring(vch:symVar,30)"/>
                </varSym>
            </xsl:when>
            <xsl:otherwise>
                <varSym>nevyplněno</varSym>
            </xsl:otherwise>
        </xsl:choose>

        <datObj>
            <xsl:value-of select="vch:date"/>
        </datObj>

        <ucetni>true</ucetni>
        <!--        If missing the calculation of total price will be fucked -->
        <bezPolozek>
            <xsl:choose>
                <xsl:when test="not(../vch:voucherDetail)">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </bezPolozek>

        <!--        Choose whether the document is PRIJEM / VYDEJ-->
        <xsl:choose>
            <xsl:when test="vch:voucherType = 'receipt'">
                <typPohybuK>typPohybu.prijem</typPohybuK>
            </xsl:when>
            <xsl:otherwise>
                <typPohybuK>typPohybu.vydej</typPohybuK>
            </xsl:otherwise>
        </xsl:choose>

        <!--Stredisko-->
        <xsl:if test="vch:centre/typ:ids">
            <stredisko>
                <xsl:value-of select="concat('code:', upper-case(vch:centre/typ:ids))"/>
            </stredisko>
        </xsl:if>
        <xsl:if test="vch:activity/typ:ids">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(vch:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>

        <!--        Assing pokladna via code reference-->
        <pokladna>code:<xsl:value-of select="upper-case(vch:cashAccount/typ:ids)"/>
        </pokladna>
        <!--Bez migrace číselných řad:-->
        <typDokl>code:STANDARD</typDokl>
        <!--        Při migraci číselných řad:-->
        <!--        <typDokl>code:POKL-<xsl:value-of select="vch:number/typ:id"/></typDokl>-->

        <datUcto>
            <xsl:value-of select="vch:dateTax"/>
        </datUcto>
        <popis>
            <xsl:value-of select="f:textSubstring(vch:text, 255)"/>
        </popis>

        <!--        Foreign currency-->
        <xsl:if test="../vch:voucherSummary/vch:foreignCurrency">
            <mena>code:<xsl:value-of
              select="../vch:voucherSummary/vch:foreignCurrency/typ:currency/typ:ids"/>
            </mena>
            <kurz>
                <xsl:value-of select="../vch:voucherSummary/vch:foreignCurrency/typ:rate"/>
            </kurz>
            <kurzMnozstvi>
                <xsl:value-of select="../vch:voucherSummary/vch:foreignCurrency/typ:amount"/>
            </kurzMnozstvi>
        </xsl:if>

        <!--        Accounting assigned by accounting ID and year -->
        <xsl:if test="vch:accounting and vch:accounting/typ:ids != 'Bez' and vch:accounting/typ:ids != 'Ručně'">
            <typUcOp>
                <xsl:value-of select="concat('ext:POHODA:', vch:accounting/typ:id, '-', $year)"/>
            </typUcOp>
        </xsl:if>

        <!--        Partner identity-->
        <xsl:apply-templates select="vch:partnerIdentity"/>
        <!--        Insert VAT Mapping from external method-->
        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>
        <!--        Vat rates deduced from prices-->
        <xsl:variable name="vatRates">
            <!--            TODO: Vitadio does not use 3 VAT types. Figure out how to cover programmatically!! -->
            <xsl:if test="../vch:voucherSummary/*:homeCurrency/*:priceLowVAT > 0">12</xsl:if>
            <!--            <xsl:if test="vch:voucherSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>-->
            <xsl:if test="../vch:voucherSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
        </xsl:variable>
        <!--Decide the agenda type-->
        <xsl:variable name="agendaType">
            <xsl:if test="vch:voucherType = 'expense'">VYDEJ</xsl:if>
            <xsl:if test="vch:voucherType = 'receipt'">PRIJEM</xsl:if>
        </xsl:variable>

        <!--        If no items in document ==> call template to fill the account numbers for overall invoice-->
        <!--        If items are present in document ==>  use accounting for account numbers-->
        <xsl:choose>
            <xsl:when test="not(../vch:voucherDetail)">
                <xsl:call-template name="createAccountingForSummary">
                    <xsl:with-param name="accountingId"
                                    select="concat('ext:POHODA:', vch:accounting/typ:id, '-', $year)"/>
                    <xsl:with-param name="vatRates" select="$vatRates"/>
                    <xsl:with-param name="documentNumber" select="vch:number/typ:numberRequested"/>
                    <xsl:with-param name="documentId" select="vch:id"/>
                    <xsl:with-param name="agendaType" select="$agendaType"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="accountingId"
                              select="concat('ext:POHODA:', vch:accounting/typ:id, '-', $year)"/>

                <xsl:variable name="accountAssignment" as="node()*">
                    <xsl:sequence
                      select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=$accountingId]"/>
                </xsl:variable>

                <xsl:if test="$accountAssignment and not(string($accountAssignment) = '')">
                    <xsl:if test="$agendaType = 'PRIJEM'">
                        <primUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                        </primUcet>
                        <protiUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                        </protiUcet>
                    </xsl:if>
                    <xsl:if test="$agendaType = 'VYDEJ'">
                        <primUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                        </primUcet>
                        <protiUcet>
                            <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                        </protiUcet>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="vch:voucherSummary">
        <xsl:if test="not(../vch:voucherDetail)">

            <xsl:if test="vch:homeCurrency/typ:priceNone != 0">
                <sumOsv>
                    <xsl:value-of select="vch:homeCurrency/typ:priceNone"/>
                </sumOsv>
            </xsl:if>

            <xsl:if test="vch:homeCurrency/typ:priceLowSum != 0">
                <sumCelkSniz>
                    <xsl:value-of select="vch:homeCurrency/typ:priceLowSum"/>
                </sumCelkSniz>
            </xsl:if>

            <xsl:if test="vch:homeCurrency/typ:price3Sum != 0">
                <sumCelkSniz2>
                    <xsl:value-of select="vch:homeCurrency/typ:price3Sum"/>
                </sumCelkSniz2>
            </xsl:if>

            <xsl:if test="vch:homeCurrency/typ:priceHighSum != 0">
                <sumCelkZakl>
                    <xsl:value-of select="vch:homeCurrency/typ:priceHighSum"/>
                </sumCelkZakl>
            </xsl:if>

            <xsl:if test="vch:homeCurrency/typ:priceHighVAT != 0">
                <szbDphZakl>
                    <xsl:value-of select="vch:homeCurrency/typ:priceHighVAT/@rate"/>
                </szbDphZakl>
            </xsl:if>

            <xsl:if test="vch:homeCurrency/typ:priceLowVAT != 0">
                <szbDphSniz>
                    <xsl:value-of select="vch:homeCurrency/typ:priceLowVAT/@rate"/>
                </szbDphSniz>
            </xsl:if>
            <xsl:if test="vch:homeCurrency/typ:price3VAT != 0">
                <szbDphSniz2>
                    <xsl:value-of select="vch:homeCurrency/typ:price3VAT/@rate"/>
                </szbDphSniz2>
            </xsl:if>
        </xsl:if>

    </xsl:template>

    <xsl:template match="vch:voucherDetail">
        <polozkyIntDokladu removeAll="true">
            <xsl:apply-templates select="vch:voucherItem"/>
        </polozkyIntDokladu>
    </xsl:template>

    <xsl:template match="vch:voucherItem">
        <pokladni-pohyb-polozka>
            <id>
                <xsl:value-of select="concat('ext:POHODA:', ../../vch:voucherHeader/vch:id,'-',$year)"/>
            </id>

            <nazev>
                <xsl:value-of select="vch:text"/>
            </nazev>

            <mnozMj>
                <xsl:value-of select="f:validateAndTrimNumber(vch:quantity,19)"/>
            </mnozMj>

            <typPolozkyK>typPolozky.obecny</typPolozkyK>

            <xsl:choose>
                <xsl:when
                  test="vch:accounting/typ:ids and vch:accounting/typ:ids != 'Bez' and vch:accounting/typ:ids != 'Ručně'">
                    <typUcOp evidencePath="predpis-zauctovani">
                        <xsl:value-of select="concat('ext:POHODA:', vch:accounting/typ:id, '-', $year)"/>
                    </typUcOp>
                    <kopTypUcOp>false</kopTypUcOp>
                </xsl:when>
                <xsl:otherwise>
                    <kopTypUcOp>true</kopTypUcOp>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="vch:centre/typ:ids">
                <stredisko>
                    <xsl:value-of select="concat('code:', upper-case(vch:centre/typ:ids))"/>
                </stredisko>
            </xsl:if>
            <xsl:if test="vch:activity/typ:ids">
                <cinnost>
                    <xsl:value-of select="concat('code:', upper-case(vch:activity/typ:ids))"/>
                </cinnost>
            </xsl:if>
            <xsl:if test="vch:contract">
                <zakazka>code:<xsl:value-of select="upper-case(vch:contract/typ:ids)"/>
                </zakazka>
            </xsl:if>


            <!--  Price type
                without VAT - typCeny.bezDph
                 VAT incl. - typCeny.sDph  -->
            <typCenyDphK>
                <xsl:choose>
                    <xsl:when test="vch:rateVAT/@value = 0">typCeny.bezDph</xsl:when>
                    <xsl:otherwise>typCeny.sDph</xsl:otherwise>
                </xsl:choose>
            </typCenyDphK>

            <!--  VAT rate category
              VAT-exempt - typSzbDph.dphOsv
              Reduced - typSzbDph.dphSniz
              2nd reduced  - typSzbDph.dphSniz2
              Basic - typSzbDph.dphZakl  -->
            <typSzbDphK>
                <xsl:choose>
                    <xsl:when test="vch:rateVAT/@value = 21">typSzbDph.dphZakl</xsl:when>
                    <xsl:when test="vch:rateVAT/@value = 15">typSzbDph.dphSniz</xsl:when>
                    <xsl:when test="vch:rateVAT/@value = 10">typSzbDph.dphSniz2</xsl:when>
                    <xsl:when test="vch:rateVAT/@value = 0">typSzbDph.dphOsv</xsl:when>
                </xsl:choose>
            </typSzbDphK>

            <cenaMj>
                <xsl:value-of select="vch:homeCurrency/typ:priceSum"/>
            </cenaMj>

            <xsl:variable name="agendaType">
                <xsl:if test="../../vch:voucherHeader/vch:voucherType = 'expense'">VYDEJ</xsl:if>
                <xsl:if test="../../vch:voucherHeader/vch:voucherType = 'receipt'">PRIJEM</xsl:if>
            </xsl:variable>
            <!--            Call template to assign account values from JOURNAL-->
            <xsl:call-template name="createAccountingForItem">
                <xsl:with-param name="documentNumber" select="../../vch:voucherHeader/vch:number/typ:numberRequested"/>
                <xsl:with-param name="documentId" select="../../vch:voucherHeader/vch:id"/>
                <xsl:with-param name="documentItem" select="current()"/>
                <xsl:with-param name="agendaType">BOTH</xsl:with-param>
                <!--                <xsl:with-param name="agendaType" select="$agendaType"/>-->
            </xsl:call-template>

        </pokladni-pohyb-polozka>
    </xsl:template>

    <xsl:template match="vch:partnerIdentity">
        <xsl:if test="typ:id">
            <firma>
                <xsl:value-of select="concat('ext:POHODA:', typ:id, '-', $year)"/>
            </firma>
        </xsl:if>

        <xsl:if test="not(typ:id)">
            <nazFirmy>
                <xsl:value-of select="typ:address/typ:company"/>
            </nazFirmy>
            <mesto>
                <xsl:value-of select="typ:address/typ:city"/>
            </mesto>
            <ulice>
                <xsl:value-of select="typ:address/typ:street"/>
            </ulice>
            <ic>
                <xsl:value-of select="typ:address/typ:ico"/>
            </ic>
            <dic>
                <xsl:value-of select="typ:address/typ:dic"/>
            </dic>
            <psc>
                <xsl:value-of select="typ:address/typ:zip"/>
            </psc>

        </xsl:if>
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
                      select="document($journal_pohoda)/items/item[evidenceId = 27 and documentId = $documentId
                      and not(starts-with(text/text(), 'DPH'))][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                                            Prijem ==>    PRIM UCET = DAL acc-->
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
                              select="document($journal_pohoda)/items/item[evidenceId = 27 and documentId = $documentId and starts-with(text/text(), 'DPH')][1]"/>

                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <!--                         Pro vydej = DAL. Pro prijem = MD -->
                        <xsl:choose>
                            <xsl:when test="$agendaType = 'PRIJEM'">
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
                            </xsl:when>
                            <xsl:otherwise>
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
                    <xsl:when test="$accountAssignment and not(string($accountAssignment) = '')">
                        <xsl:if test="$agendaType = 'PRIJEM'">
                            <primUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                            </primUcet>
                            <protiUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                            </protiUcet>
                        </xsl:if>
                        <xsl:if test="$agendaType = 'VYDEJ'">
                            <primUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                            </primUcet>
                            <protiUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                            </protiUcet>
                        </xsl:if>
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
            <xsl:value-of select="$documentItem/*:homeCurrency/typ:price"/>
        </xsl:variable>
        <xsl:variable name="priceVat">
            <xsl:value-of select="$documentItem/*:homeCurrency/typ:priceVAT"/>
        </xsl:variable>
        <xsl:variable name="account"
                      select="document($journal_pohoda)/items/item[evidenceId = 27 and documentId = $documentId and xs:decimal(amount) = xs:decimal($price)][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:if test="$agendaType = 'PRIJEM' or $agendaType = 'BOTH'">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <!--                    MD account-->
                    <zklMdUcet>code:<xsl:value-of select="$account/mdAccount"/>
                    </zklMdUcet>
                </xsl:if>
                <xsl:if test="$agendaType = 'VYDEJ' or $agendaType = 'BOTH'">
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <!--                    DAL account-->
                    <zklDalUcet>code:<xsl:value-of select="$account/dAccount"/>
                    </zklDalUcet>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>ACC_PROBLEM: Záučtovaní dokladu neproběhlo. Nenalezen záznam v účetním deníku pro dokument
                    s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of select="$documentNumber"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>


        <xsl:variable name="vatAccount"
                      select="document($journal_pohoda)/items/item[evidenceId = 27 and documentId = $documentId and xs:decimal(amount) = xs:decimal($priceVat) and starts-with(text/text(), 'DPH')][1]"/>

        <xsl:choose>
            <xsl:when test="$vatAccount and $vatAccount != ''">
                <xsl:if test="$agendaType = 'PRIJEM' or $agendaType = 'BOTH'">
                    <kopDphMdUcet>false</kopDphMdUcet>
                    <dphMdUcet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                    </dphMdUcet>
                </xsl:if>

                <xsl:if test="$agendaType = 'VYDEJ' or $agendaType = 'BOTH'">
                    <kopDphDalUcet>false</kopDphDalUcet>
                    <dphDalUcet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                    </dphDalUcet>
                </xsl:if>
            </xsl:when>

            <xsl:otherwise>
                <xsl:if test="number($priceVat)">
                    <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v účetním deníku
                        pro dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of
                          select="$documentNumber"/>
                    </xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>

</xsl:stylesheet>