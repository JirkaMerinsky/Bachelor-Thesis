<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
                xmlns:dc="http://www.dcos.cz/flexi-migration/document-common">

    <xsl:import href="general/document-common.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>
    <xsl:param name="journal_pohoda"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:invoice[(inv:invoiceDetail)]">
        <faktura-prijata>
            <bezPolozek>false</bezPolozek>
            <xsl:apply-templates select="inv:invoiceHeader"/>
            <xsl:apply-templates select="inv:invoiceDetail"/>
            <xsl:if test="inv:invoiceSummary/inv:foreignCurrency">
                <mena>code:<xsl:value-of
                  select="upper-case(inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids)"/>
                </mena>
                <kurz>
                    <xsl:value-of select="inv:foreignCurrency/typ:rate"/>
                </kurz>
            </xsl:if>


            <!--            Pokud bez polozek tak vzit accounting z account-assignment-->
            <!--             Jde udelat lepe, je potreba pak doresit ktere polozky kopirovat a ktere ne ?? -->
            <xsl:variable name="accountingIds">
                <xsl:choose>
                    <xsl:when test="inv:invoiceHeader/inv:accounting/typ:ids != 'repre'">
                        <xsl:value-of select="upper-case(inv:invoiceHeader/inv:accounting/typ:id)"/>
                    </xsl:when>
                    <xsl:otherwise>REPREPRIFAKT</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>


            <xsl:variable name="accountAssignment" as="node()*">
                <xsl:sequence
                  select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[kod=$accountingIds]"/>
            </xsl:variable>

            <xsl:if test="$accountAssignment and not($accountAssignment = '')">
                <protiUcet>
                    <xsl:value-of select="$accountAssignment/protiUcetPrijem"/>
                </protiUcet>
                <primUcet>
                    <xsl:value-of select="$accountAssignment/protiUcetVydej"/>
                </primUcet>
            </xsl:if>

            <!--            TODO: Test without-->
        </faktura-prijata>
    </xsl:template>
    <!--    Případ, ve kterém faktura neobsahuje detail, tudíž ani položky-->
    <xsl:template match="lst:invoice[not(inv:invoiceDetail)]">
        <faktura-prijata>
            <bezPolozek>true</bezPolozek>
            <xsl:apply-templates select="inv:invoiceHeader"/>
            <xsl:apply-templates select="inv:invoiceSummary"/>
            <xsl:if test="inv:invoiceSummary/inv:foreignCurrency">
                <mena>code:<xsl:value-of
                  select="upper-case(inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids)"/>
                </mena>
                <kurz>
                    <xsl:value-of select="inv:foreignCurrency/typ:rate"/>
                </kurz>
            </xsl:if>


            <!--        Vat rates deduced from prices-->
            <xsl:variable name="vatRates">
                <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:priceLowVAT > 0">15</xsl:if>
                <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
                <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
            </xsl:variable>
            <!--        Call template to fill the account numbers for overall invoice-->
            <xsl:call-template name="createAccountingForSummary">
                <xsl:with-param name="accountingIds" select="upper-case(inv:invoiceHeader/inv:accounting/typ:id)"/>
                <xsl:with-param name="vatRates" select="$vatRates"/>
                <xsl:with-param name="documentNumber" select="inv:invoiceHeader/inv:number/typ:numberRequested"/>
                <xsl:with-param name="documentId" select="inv:invoiceHeader/inv:id"/>
                <xsl:with-param name="agendaType">PRIJEM</xsl:with-param>
            </xsl:call-template>

        </faktura-prijata>
    </xsl:template>

    <xsl:template match="inv:invoiceHeader">
        <!--        Assign ID of POHODA-->
        <id>
            <xsl:value-of select="concat('ext:POHODA:', *:id, '-', $year)"/>
        </id>
        <id>ext:POHODA:<xsl:value-of select="*:number/typ:numberRequested"/>
        </id>
        <!--        Při nepřevádění číselných řad:-->
        <typDokl>code:ZÁLOHA</typDokl>
        <!--        Při převádění číselných řad:-->
        <!--        <typDokl>code:PRIFAKT-<xsl:value-of select="inv:number/typ:id"/></typDokl>-->
        <!--        <typDokl>ext:POHODA:receivedInvoice</typDokl>-->
        <zbyvaUhraditMen>0</zbyvaUhraditMen>
        <kod>
            <xsl:value-of select="inv:number/typ:numberRequested"/>
        </kod>
        <cisDosle>
            <xsl:choose>
                <!--                Received invoice shall use original document number -->
                <xsl:when test="inv:originalDocument">
                    <xsl:value-of select="inv:originalDocument"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--                    If original document number is missing, use variable symbol instead-->
                    <xsl:value-of select="inv:symVar"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="inv:contract">
                <zakazka>code:<xsl:value-of select="upper-case(inv:contract/typ:ids)"/>
                </zakazka>
            </xsl:if>

        </cisDosle>
        <xsl:if test="inv:symConst">
            <konSym if-not-found="create">code:<xsl:value-of select="inv:symConst"/>
            </konSym>
        </xsl:if>
        <varSym>
            <xsl:value-of select="inv:symVar"/>
        </varSym>
        <datVyst>
            <xsl:value-of select="inv:date"/>
        </datVyst>
        <datSazbyDph>
            <xsl:value-of select="inv:dateTax"/>
        </datSazbyDph>
        <datTermin>
            <xsl:value-of select="inv:dateDue"/>
        </datTermin>
        <datSplat>
            <xsl:value-of select="inv:dateDue"/>
        </datSplat>
        <!--        <duzpUcto>-->
        <!--            <xsl:value-of select="inv:dateAccounting"/>-->
        <!--        </duzpUcto>-->

        <!--        TODO: add bank account -->

        <xsl:if test="inv:paymentAccount">
            <buc>
                <xsl:value-of select="inv:paymentAccount/typ:accountNo"/>
            </buc>
            <smerKod>
                <xsl:value-of select="concat('code:', inv:paymentAccount/typ:bankCode)"/>
            </smerKod>
        </xsl:if>


        <xsl:choose>
            <xsl:when test="inv:dateKHDPH">
                <duzpUcto>
                    <xsl:value-of select="inv:dateTax"/>
                </duzpUcto>
                <duzpPuv>
                    <xsl:value-of select="inv:dateKHDPH"/>
                </duzpPuv>
            </xsl:when>
            <xsl:otherwise>
                <duzpUcto>
                    <xsl:value-of select="inv:dateAccounting"/>
                </duzpUcto>
                <duzpPuv>
                    <xsl:value-of select="inv:dateTax"/>
                </duzpPuv>
            </xsl:otherwise>
        </xsl:choose>
        <popis>
            <xsl:value-of select="inv:text"/>
        </popis>
        <kontaktJmeno>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:name"/>
        </kontaktJmeno>
        <kontaktEmail>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:email"/>
        </kontaktEmail>
        <kontaktTel>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:phone"/>
        </kontaktTel>
        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>
        <xsl:choose>
            <xsl:when test="inv:partnerIdentity/typ:id">
                <firma>
                    <xsl:value-of select="concat('ext:POHODA:', inv:partnerIdentity/typ:id, '-', $year)"/>
                </firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="adresaFirmy"/>
            </xsl:otherwise>
        </xsl:choose>
        <formaUhradyCis>
            <xsl:choose>
                <xsl:when test="inv:paymentType/typ:ids='Příkazem'">3</xsl:when>
                <xsl:when test="inv:paymentType/typ:ids='Hotově'">1</xsl:when>
                <xsl:when test="inv:paymentType/typ:ids='Zálohou'">1</xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </formaUhradyCis>

        <!--        TODO: accounting from ID instead of IDS -->
        <xsl:if test="inv:accounting and inv:accounting/typ:ids != 'Bez' and inv:accounting/typ:ids != 'Ručně'">
            <typUcOp>
                <xsl:value-of select="concat('ext:POHODA:', inv:accounting/typ:id, '-', $year)"/>
            </typUcOp>
        </xsl:if>
        <!--        Insert VAT mapping from external method-->
        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>

        <xsl:if test="inv:centre/typ:ids">
            <stredisko>
                <xsl:value-of select="concat('code:', upper-case(inv:centre/typ:ids))"/>
            </stredisko>
        </xsl:if>
        <xsl:if test="inv:activity/typ:ids">
            <cinnost>
                <xsl:value-of select="concat('code:', upper-case(inv:activity/typ:ids))"/>
            </cinnost>
        </xsl:if>

    </xsl:template>

    <xsl:template match="inv:invoiceDetail">
        <polozkyFaktury>
            <xsl:apply-templates select="inv:invoiceItem"/>
        </polozkyFaktury>
    </xsl:template>

    <xsl:template match="inv:invoiceItem">
        <faktura-prijata-polozka>
            <id>
                <xsl:value-of select="concat('ext:POHODA:', inv:id, '-', $year)"/>
            </id>
            <nazev>
                <xsl:value-of select="inv:text"/>
            </nazev>
            <xsl:if test="inv:centre/typ:ids">
                <stredisko>
                    <xsl:value-of select="concat('code:', upper-case(inv:centre/typ:ids))"/>
                </stredisko>
            </xsl:if>
            <xsl:if test="inv:activity/typ:ids">
                <cinnost>
                    <xsl:value-of select="concat('code:', upper-case(inv:activity/typ:ids))"/>
                </cinnost>
                <xsl:choose>
                    <xsl:when
                      test="inv:accounting/typ:ids and inv:accounting/typ:ids != 'Bez' and inv:accounting/typ:ids != 'Ručně'">
                        <typUcOp evidencePath="predpis-zauctovani">
                            <xsl:value-of select="concat('ext:POHODA:', inv:accounting/typ:id, '-', $year)"/>
                        </typUcOp>
                        <kopTypUcOp>false</kopTypUcOp>
                    </xsl:when>
                    <xsl:otherwise>
                        <kopTypUcOp>true</kopTypUcOp>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="inv:contract">
                    <zakazka>code:<xsl:value-of select="upper-case(inv:contract/typ:ids)"/>
                    </zakazka>
                </xsl:if>

            </xsl:if>
            <!--                        <cenik>code:<xsl:value-of select="inv:code"/>-->
            <!--                        </cenik>-->
            <!--                        <sklad>code:01</sklad>-->
            <mnozMj>
                <xsl:value-of select="inv:quantity"/>
            </mnozMj>

            <xsl:choose>
                <xsl:when test="inv:unit !='' and inv:unit !=' '">
                    <mj>code:<xsl:value-of select="upper-case(inv:unit)"/>
                    </mj>
                </xsl:when>
                <xsl:otherwise>
                    <mj>code:KS</mj>
                </xsl:otherwise>
            </xsl:choose>

            <typPolozkyK>typPolozky.obecny</typPolozkyK>
            <typSazbyDph>
                <xsl:call-template name="typSazbaDph">
                    <xsl:with-param name="inputDph" select="inv:rateVAT"/>
                </xsl:call-template>
            </typSazbyDph>
            <szbDph>
                <xsl:value-of select="inv:rateVAT/@value"/>
            </szbDph>

            <typCenyDphK>
                <xsl:choose>
                    <xsl:when test="inv:rateVAT/@value != 0">typCeny.sDph</xsl:when>
                    <xsl:otherwise>typCeny.bezDph</xsl:otherwise>
                </xsl:choose>
            </typCenyDphK>

            <xsl:choose>
                <xsl:when test="inv:foreignCurrency">
                    <cenaMj>
                        <xsl:value-of select="inv:foreignCurrency/typ:unitPrice"/>
                    </cenaMj>

                </xsl:when>
                <xsl:otherwise>
                    <cenaMj>
                        <xsl:value-of select="inv:homeCurrency/typ:unitPrice"/>
                    </cenaMj>

                </xsl:otherwise>
            </xsl:choose>
            <slevaPol>
                <xsl:value-of select="inv:discountPercentage"/>
            </slevaPol>

            <kopTypUcOp>false</kopTypUcOp>
            <!--            takhle to má být-->
            <!--            <xsl:if test="inv:accounting">-->
            <!--                -->
            <!--                <typUcOp>-->
            <!--                    <xsl:value-of select="concat('code:', upper-case(inv:accounting/typ:ids))"/>-->
            <!--                </typUcOp>-->
            <!--            </xsl:if>-->


            <!--            Call template to assing account values from JOURNAL-->
            <xsl:call-template name="createAccountingForItem">
                <xsl:with-param name="documentNumber" select="../../inv:invoiceHeader/inv:number/typ:numberRequested"/>
                <xsl:with-param name="documentId" select="../../inv:invoiceHeader/inv:id"/>
                <xsl:with-param name="documentItem" select="current()"/>
                <xsl:with-param name="agendaType">PRIJEM</xsl:with-param>
            </xsl:call-template>

        </faktura-prijata-polozka>
    </xsl:template>

    <xsl:template match="inv:invoiceSummary">
        <xsl:choose>
            <xsl:when test="inv:foreignCurrency">
                <xsl:call-template name="summaryForeignCurrency"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="summaryHomeCurrency"/>
            </xsl:otherwise>
        </xsl:choose>


    </xsl:template>
    <xsl:template name="typSazbaDph">
        <xsl:param name="inputDph"/>
        <xsl:choose>
            <xsl:when test="$inputDph = 'high'">typSzbDph.dphZakl</xsl:when>
            <xsl:when test="$inputDph = 'low'">typSzbDph.dphSniz</xsl:when>
            <xsl:when test="$inputDph = 'third'">typSzbDph.dphSniz2</xsl:when>
            <xsl:when test="$inputDph = 'none'">typSzbDph.dphOsv</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="sazbaDph">
        <xsl:param name="inputDph"/>
        <xsl:choose>
            <xsl:when test="$inputDph = 'high'">21</xsl:when>
            <xsl:when test="$inputDph = 'low'">15</xsl:when>
            <xsl:when test="$inputDph = 'third'">10</xsl:when>
            <xsl:when test="$inputDph = 'none'">0</xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="adresaFirmy">
        <xsl:choose>
            <xsl:when test="inv:partnerIdentity/typ:address/typ:company">
                <nazFirmy>
                    <xsl:value-of select="inv:partnerIdentity/typ:address/typ:company"/>
                </nazFirmy>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>
                    <xsl:value-of select="inv:partnerIdentity/typ:address/typ:name"/>
                </nazFirmy>
            </xsl:otherwise>
        </xsl:choose>
        <ulice>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:street"/>
        </ulice>
        <mesto>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:city"/>
        </mesto>
        <psc>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:zip"/>
        </psc>
        <ic>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:ico"/>
        </ic>
        <dic>
            <xsl:value-of select="inv:partnerIdentity/typ:address/typ:dic"/>
        </dic>
    </xsl:template>
    <xsl:template name="summaryForeignCurrency">
        <!--        <sumZklZakl>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceHigh"/>-->
        <!--        </sumZklZakl>-->
        <!--        <sumDphZakl>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceHighVAT"/>-->
        <!--        </sumDphZakl>-->
        <!--        <sumDphSniz>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceLowVAT"/>-->
        <!--        </sumDphSniz>-->
        <!--        <sumDphSniz2>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:price3VAT"/>-->
        <!--        </sumDphSniz2>-->
        <!--        <sumOsv>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceNone"/>-->
        <!--        </sumOsv>-->
        <!--        <sumCelkZakl>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceHighSum"/>-->
        <!--        </sumCelkZakl>-->
        <!--        <sumCelkem>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceSum"/>-->
        <!--        </sumCelkem>-->
        <!--        <sumOsvMen>-->
        <!--            <xsl:value-of select="inv:foreignCurrency/typ:priceSum"/>-->
        <!--        </sumOsvMen>-->

        <!--        TODO zkontrolovat jestli je vzdy bez DPH nebo jestli je potreba kouknout do home currency a podle toho assignout foreign currency-->
        <sumOsvMen>
            <xsl:value-of select="inv:foreignCurrency/typ:priceSum"/>
        </sumOsvMen>


    </xsl:template>
    <xsl:template name="summaryHomeCurrency">
        <sumOsv>
            <xsl:value-of select="inv:homeCurrency/typ:priceNone"/>
        </sumOsv>
        <sumCelkZakl>
            <xsl:value-of select="inv:homeCurrency/typ:priceHighSum"/>
        </sumCelkZakl>
        <sumCelkSniz>
            <xsl:value-of select="inv:homeCurrency/typ:priceLowSum"/>
        </sumCelkSniz>
        <sumCelkSniz2>
            <xsl:value-of select="inv:homeCurrency/typ:price3Sum"/>
        </sumCelkSniz2>
        <sumCelkem>
            <xsl:value-of select="inv:homeCurrency/typ:priceSum"/>
        </sumCelkem>


    </xsl:template>

    <!--    Template to create accounting detail for agenda (not for item). Fill in accounts -->
    <xsl:template name="createAccountingForSummary">
        <!--        VAT rate of document of the interest in POHODA xml file-->
        <xsl:param name="vatRates"/>
        <!--Number of the document of the interest in xml POHODA file. -->
        <xsl:param name="documentNumber"/>
        <!--IDS of the accounting node ==> references the  "PREDPISY ZAUCTOVANI" in ABRA  -->
        <xsl:param name="accountingIds"/>
        <!--        Id of the document of the interest, usually placed in agenda header in POHODA xml file-->
        <xsl:param name="documentId"/>
        <!--        Decide wheteher it is PRIJEM or VYDEJ (prijata nebo vydana faktura popripade jiny typ agendy)-->
        <xsl:param name="agendaType"/>

        <!--        References the row in JOURNAL POHODA. Contains details about account-->
        <xsl:variable name="account"
                      select="document($journal_pohoda)/items/item[evidenceId = 3 and documentId = $documentId and not(starts-with(text, 'DPH'))][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                    Prijem ==>    PRIM UCET = DAL acc-->
                        <primUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </protiUcet>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--             Vydej ==>        PRIM UCET = MD acc -->
                        <primUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </primUcet>
                        <protiUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </protiUcet>
                    </xsl:otherwise>
                </xsl:choose>
                <!--        References the row in JOURNAL POHODA. Contains details about DPH account-->
                <xsl:variable name="vatAccount"
                              select="document($journal_pohoda)/items/item[evidenceId = 44 and documentId = $documentId and starts-with(text, 'DPH')][1]"/>

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
                                    <xsl:when test="contains($vatRates, '15')">
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
                                    <xsl:when test="contains($vatRates, '15')">
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
                        <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v účetním deníku
                            pro dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of
                              select="$documentNumber"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>

                <xsl:variable name="accountAssignment" as="node()*">
                    <xsl:sequence
                      select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[kod=$accountingIds]"/>
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$accountAssignment and not($accountAssignment = '')">
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
                              select="$documentNumber"/>. IDS předkontace:
                            <xsl:value-of select="$accountingIds"/>
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
                      select="document($journal_pohoda)/items/item[evidenceId = 3 and documentId = $documentId and not(starts-with(text, 'DPH')) and xs:decimal(amount) = xs:decimal($price)][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">

                <xsl:if test="$agendaType = 'PRIJEM'">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <!--                    MD account-->
                    <zklMdUcet>code:<xsl:value-of select="$account/mdAccount"/>
                    </zklMdUcet>
                </xsl:if>
                <xsl:if test="$agendaType = 'VYDEJ'">
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <!--                    DAL account-->
                    <zklDalUcet>code:<xsl:value-of select="$account/dAccount"/>
                    </zklDalUcet>
                </xsl:if>

                <xsl:variable name="vatAccount"
                              select="document($journal_pohoda)/items/item[evidenceId = 3 and documentId = $documentId and starts-with(text, 'DPH') and xs:decimal(amount) = xs:decimal($priceVat)][1]"/>

                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">

                        <xsl:choose>
                            <xsl:when test="$agendaType = 'PRIJEM'">
                                <kopDphMdUcet>false</kopDphMdUcet>
                                <dphMdUcet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                                </dphMdUcet>
                            </xsl:when>

                            <xsl:otherwise>
                                <kopDphDalUcet>false</kopDphDalUcet>
                                <dphDalUcet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                                </dphDalUcet>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v účetním deníku
                            pro dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:<xsl:value-of
                              select="$documentNumber"/>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>