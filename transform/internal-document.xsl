<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:json="http://json.org/"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:int="http://www.stormware.cz/schema/version_2/intDoc.xsd"
    xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/document-common.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>
    <xsl:param name="journal_pohoda"/>


    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:intDoc">
        <interni-doklad json:force-array="true">
            <xsl:apply-templates select="int:intDocHeader"/>
            <xsl:apply-templates select="int:intDocDetail"/>
            <xsl:apply-templates select="int:intDocSummary"/>

        </interni-doklad>
    </xsl:template>

    <xsl:template match="int:intDocHeader">
        <id>{gi:generateId(int:id, $year, true(), false())}</id>
        <kod>{int:number/typ:numberRequested}</kod>
        <zamekK showAs="Open">zamek.otevreno</zamekK>
        <cisDosle>
            <xsl:choose>
                <!--                Received invoice shall use original document number -->
                <xsl:when test="int:originalDocument">{int:originalDocument}</xsl:when>
                <!--                    If original document number is missing, use variable symbol instead-->
                <xsl:otherwise>{int:symVar}</xsl:otherwise>
            </xsl:choose>
        </cisDosle>
        <varSym>{int:symVar}</varSym>
        <datVyst>{int:date}</datVyst>
        <xsl:choose>
            <xsl:when test="int:dateKHDPH">
                <duzpUcto>{int:dateTax}</duzpUcto>
                <duzpPuv>{int:dateKHDPH}</duzpPuv>
            </xsl:when>
            <xsl:otherwise>
                <duzpUcto>{int:dateAccounting}</duzpUcto>
                <duzpPuv>{int:dateTax}</duzpPuv>
            </xsl:otherwise>
        </xsl:choose>
        <datSazbyDph>{int:dateTax}</datSazbyDph>
        <popis>{int:text}</popis>
        <poznam>{int:note}</poznam>
        <typDokl>code:INT. DOKLAD</typDokl>
        <rada>code:INTERNÍ DOKLADY</rada>

        <!--        Solve it - if missing zauctovani put false, otherwise true-->
        <xsl:variable name="ucetni" select="not(contains(int:accounting/typ:ids, 'BEZ'))"/>
        <ucetni>{$ucetni}</ucetni>

        <!--Stredisko-->
        <xsl:if test="int:centre">
            <stredisko>code:{upper-case(int:centre/typ:ids)}</stredisko>
        </xsl:if>

        <!--                Zakazka-->
        <xsl:if test="int:contract">
            <zakazka>code:{upper-case(int:contract/typ:ids)}</zakazka>
        </xsl:if>

        <!--        Foreign currency-->
        <xsl:if test="../int:intDocSummary/int:foreignCurrency">
            <mena>code:{../int:intDocSummary/int:foreignCurrency/typ:currency/typ:ids}</mena>
            <kurz>{../int:intDocSummary/int:foreignCurrency/typ:rate}</kurz>
            <kurzMnozstvi>{../int:intDocSummary/int:foreignCurrency/typ:amount}</kurzMnozstvi>
        </xsl:if>

        <xsl:if
            test="int:accounting and int:accounting/typ:ids != 'Bez' and int:accounting/typ:ids != 'Ručně'">
            <typUcOp>ext:POHODA:{int:accounting/typ:id}</typUcOp>
        </xsl:if>

        <!--        Assign partner identity-->
        <xsl:apply-templates select="int:partnerIdentity"/>
        <!--        Insert VAT mapping from external method-->
        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>

        <!--        Apply the template only if document has no items related-->
        <xsl:if test="not(../int:intDocDetail)">
            <!--        Vat rates deduced from prices-->
            <xsl:variable name="vatRates">
                <xsl:if test="../int:intDocSummary/*:homeCurrency/*:priceLowVAT > 0">12</xsl:if>
                <xsl:if test="../int:intDocSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
                <xsl:if test="../int:intDocSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
            </xsl:variable>
            <!--        Call template to add account values from JOURNAL POHODA-->
            <xsl:call-template name="createAccountingForSummary">
                <xsl:with-param name="accountingId"
                    select="concat('ext:POHODA:', int:accounting/typ:id, '-', $year)"/>
                <xsl:with-param name="vatRates" select="$vatRates"/>
                <xsl:with-param name="documentNumber" select="int:number/typ:numberRequested"/>
                <xsl:with-param name="documentId" select="int:id"/>
                <xsl:with-param name="agendaType">PRIJEM</xsl:with-param>
            </xsl:call-template>
        </xsl:if>

        <xsl:if test="../int:intDocDetail">
            <xsl:variable name="accountingId" select="'ext:POHODA:' || int:accounting/typ:id"/>

            <xsl:variable name="accountAssignment" as="node()*">
                <xsl:sequence
                    select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id = $accountingId]"
                />
            </xsl:variable>

            <xsl:if test="$accountAssignment and not(string($accountAssignment) = '')">
                <primUcet>{$accountAssignment/protiUcetPrijem}</primUcet>
                <protiUcet>{$accountAssignment/protiUcetVydej}</protiUcet>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="int:partnerIdentity">
        <xsl:if test="typ:id">
            <firma>ext:POHODA:{typ:id}</firma>
        </xsl:if>

        <xsl:if test="not(typ:id)">
            <nazFirmy>{typ:address/typ:company}</nazFirmy>
            <mesto>{typ:address/typ:city}</mesto>
            <ulice>{typ:address/typ:street}</ulice>
            <ic>{typ:address/typ:ico}</ic>
            <dic>{typ:address/typ:dic}</dic>
            <psc>{typ:address/typ:zip}</psc>

        </xsl:if>
    </xsl:template>

    <xsl:template match="int:intDocDetail">
        <!--        Try to use POHODA JOURNAL for items-->
        <xsl:variable name="docId" select="../int:intDocHeader/int:id"/>
        <xsl:variable name="items">
            <xsl:sequence
                select="document($journal_pohoda)/items/item[evidenceId = 29 and documentId = $docId]"
            />
        </xsl:variable>

        <polozkyIntDokladu>
            <xsl:for-each select="$items/item">
                <interni-doklad-polozka>
                    <id>{gi:generateId(id, $year, true(), false())}</id>
                    <xsl:if test="int:centre">
                        <stredisko>code:{upper-case(int:centre/typ:ids)}</stredisko>
                    </xsl:if>
                    <xsl:if test="int:activity">
                        <cinnost>code:{upper-case(int:activity/typ:ids)}</cinnost>
                    </xsl:if>
                    <kopClenDph>true</kopClenDph>
                    <ucetni>true</ucetni>
                    <nazev>{text}</nazev>
                    <typPolozkyK>typPolozky.ucetni</typPolozkyK>
                    <mnozMj>1</mnozMj>
                    <typCenyDphK>typCeny.bezDph</typCenyDphK>
                    <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>
                    <szbDph>0.0</szbDph>
                    <cenaMj>{amount}</cenaMj>

                    <kopZklMdUcet>false</kopZklMdUcet>
                    <zklMdUcet>code:{mdAccount}</zklMdUcet>
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <zklDalUcet>code:{dAccount}</zklDalUcet>

                    <sumCelkem>{amount}</sumCelkem>

                    <xsl:choose>
                        <xsl:when
                            test="int:accounting/typ:ids and int:accounting/typ:ids != 'Bez' and int:accounting/typ:ids != 'Ručně'">
                            <typUcOp evidencePath="predpis-zauctovani"
                                >ext:POHODA:{int:accounting/typ:id}</typUcOp>
                            <kopTypUcOp>false</kopTypUcOp>
                        </xsl:when>
                        <xsl:otherwise>
                            <kopTypUcOp>true</kopTypUcOp>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:if test="int:foreignCurrency">
                        <mena>code:{../../int:intDocSummary/int:foreignCurrency/typ:currency/typ:ids}</mena>
                    </xsl:if>

                </interni-doklad-polozka>
            </xsl:for-each>
        </polozkyIntDokladu>

    </xsl:template>


    <xsl:template match="int:intDocItem">
        <interni-doklad-polozka>
            <kopClenDph>true</kopClenDph>
            <id>{gi:generateId(int:id, $year, true(), true())}</id>
            <ucetni>true</ucetni>
            <nazev>{int:text}</nazev>
            <typPolozkyK>typPolozky.ucetni</typPolozkyK>
            <mnozMj>{int:quantity}</mnozMj>

            <typCenyDphK>
                <xsl:choose>
                    <xsl:when test="int:rateVAT/@value != 0">typCeny.sDph</xsl:when>
                    <xsl:otherwise>typCeny.bezDph</xsl:otherwise>
                </xsl:choose>
            </typCenyDphK>
            <xsl:if test="int:contract">
                <zakazka>code:{upper-case(int:contract/typ:ids)}</zakazka>
            </xsl:if>


            <!--  VAT rate category
            VAT-exempt - typSzbDph.dphOsv
            Reduced - typSzbDph.dphSniz
            2nd reduced  - typSzbDph.dphSniz2
            Basic - typSzbDph.dphZakl  -->
            <typSzbDphK>
                <xsl:choose>
                    <xsl:when test="int:rateVAT/@value = 21">typSzbDph.dphZakl</xsl:when>
                    <xsl:when test="int:rateVAT/@value = 15">typSzbDph.dphSniz</xsl:when>
                    <xsl:when test="int:rateVAT/@value = 10">typSzbDph.dphSniz2</xsl:when>
                    <xsl:when test="int:rateVAT/@value = 0">typSzbDph.dphOsv</xsl:when>
                </xsl:choose>
            </typSzbDphK>
            <szbDph>{int:rateVAT/@value}</szbDph>

            <xsl:choose>
                <xsl:when test="int:foreignCurrency">
                    <sumCelkemMen>{int:foreignCurrency/typ:priceSum}</sumCelkemMen>
                </xsl:when>
                <xsl:otherwise>
                    <cenaMj>{int:homeCurrency/typ:unitPrice}</cenaMj>
                    <sumCelkem>{int:homeCurrency/typ:priceSum}</sumCelkem>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when
                    test="int:accounting/typ:ids and int:accounting/typ:ids != 'Bez' and int:accounting/typ:ids != 'Ručně'">
                    <typUcOp evidencePath="predpis-zauctovani"
                        >ext:POHODA:{int:accounting/typ:id}</typUcOp>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="int:foreignCurrency">
                <mena>code:{../../int:intDocSummary/int:foreignCurrency/typ:currency/typ:ids}</mena>
                <kurz>{int:foreignCurrency/typ:rate}</kurz>
            </xsl:if>

            <!--            Call template to assing account values from JOURNAL-->
            <xsl:call-template name="createAccountingForItem">
                <xsl:with-param name="documentNumber"
                    select="../../int:intDocHeader/int:number/typ:numberRequested"/>
                <xsl:with-param name="documentId" select="../../int:intDocHeader/int:id"/>
                <xsl:with-param name="documentItem" select="current()"/>
                <xsl:with-param name="agendaType">BOTH</xsl:with-param>
            </xsl:call-template>
        </interni-doklad-polozka>
    </xsl:template>


    <xsl:template match="int:intDocSummary">

        <xsl:if test="not(../int:intDocDetail)">
            <xsl:if test="int:homeCurrency/typ:priceLowSum != 0">
                <sumCelkSniz>{int:homeCurrency/typ:priceLowSum}</sumCelkSniz>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:price3Sum != 0">
                <sumCelkSniz2>{int:homeCurrency/typ:price3Sum}</sumCelkSniz2>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:priceHighSum != 0">
                <sumCelkZakl>{int:homeCurrency/typ:priceHighSum}</sumCelkZakl>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:priceNone != 0">
                <sumOsv>{int:homeCurrency/typ:priceNone}</sumOsv>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:priceHighVAT != 0">
                <szbDphZakl>{int:homeCurrency/typ:priceHighVAT/@rate}</szbDphZakl>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:priceLowVAT != 0">
                <szbDphSniz>{int:homeCurrency/typ:priceLowVAT/@rate}</szbDphSniz>
            </xsl:if>

            <xsl:if test="int:homeCurrency/typ:price3VAT != 0">
                <szbDphSniz2>{int:homeCurrency/typ:price3VAT/@rate}</szbDphSniz2>
            </xsl:if>
            <xsl:if test="int:foreignCurrency/typ:priceSum != 0">
                <sumOsvMen>{int:foreignCurrency/typ:priceSum}</sumOsvMen>
            </xsl:if>

            <xsl:if test="int:foreignCurrency/typ:priceSum != 0">
                <sumCelkMen>{int:foreignCurrency/typ:priceSum}</sumCelkMen>
            </xsl:if>

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
            select="document($journal_pohoda)/items/item[evidenceId = 29 and documentId = $documentId and not(starts-with(text, 'DPH'))][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:choose>
                    <xsl:when test="$agendaType = 'PRIJEM'">
                        <!--                    Prijem ==>    PRIM UCET = DAL acc-->
                        <primUcet>code:{$account/mdAccount}</primUcet>
                        <protiUcet>code:{$account/dAccount}</protiUcet>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--             Vydej ==>        PRIM UCET = MD acc -->
                        <primUcet>code:{$account/dAccount}</primUcet>
                        <protiUcet>code:{$account/mdAccount}</protiUcet>
                    </xsl:otherwise>
                </xsl:choose>
                <!--        References the row in JOURNAL POHODA. Contains details about DPH account-->
                <xsl:variable name="vatAccount"
                    select="document($journal_pohoda)/items/item[evidenceId = 29 and documentId = $documentId and starts-with(text, 'DPH')][1]"/>

                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <!--                         Pro vydej = DAL. Pro prijem = MD -->
                        <xsl:choose>
                            <xsl:when test="$agendaType = 'PRIJEM'">
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:{$vatAccount/dAccount}</dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '12')">
                                        <dphSnizUcet>code:{$vatAccount/mdAccount}</dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:{$vatAccount/dAccount}</dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="contains($vatRates, '21')">
                                        <dphZaklUcet>code:{$vatAccount/mdAccount}</dphZaklUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '12')">
                                        <dphSnizUcet>code:{$vatAccount/mdAccount}</dphSnizUcet>
                                    </xsl:when>
                                    <xsl:when test="contains($vatRates, '10')">
                                        <dphSniz2Ucet>code:{$vatAccount/mdAccount}</dphSniz2Ucet>
                                    </xsl:when>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:if test="number($vatRates) > 0">
                            <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen
                                záznam v účetním deníku pro dokument s id {$documentId}, číslo
                                dokumentu:{$documentNumber} </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:otherwise>

                <xsl:variable name="accountAssignment" as="node()*">
                    <xsl:sequence
                        select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id = $accountingId]"
                    />
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$accountAssignment and not(string($accountAssignment) = '')">
                        <primUcet>{$accountAssignment/protiUcetPrijem}</primUcet>
                        <protiUcet>{$accountAssignment/protiUcetVydej}</protiUcet>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:message>ACC_PROBLEM: Záučtovaní dokladu neproběhlo. Nenalezen záznam v
                            předkontacích pro dokument s id {$documentId}, číslo
                            dokumentu:{$documentNumber}. ID předkontace:{$accountingId}
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

        <xsl:variable name="price">{$documentItem/*:homeCurrency/typ:price}</xsl:variable>
        <xsl:variable name="priceVat">{$documentItem/*:homeCurrency/typ:priceVAT}</xsl:variable>
        <xsl:variable name="account"
            select="document($journal_pohoda)/items/item[evidenceId = 29 and documentId = $documentId and xs:decimal(amount) = xs:decimal($price)][1]"/>

        <xsl:if test="$account and $account != ''">
            <xsl:if test="$agendaType = 'PRIJEM' or $agendaType = 'BOTH'">
                <kopZklMdUcet>false</kopZklMdUcet>
                <!--                    MD account-->
                <zklMdUcet>code:{$account/mdAccount}</zklMdUcet>
            </xsl:if>
            <xsl:if test="$agendaType = 'VYDEJ' or $agendaType = 'BOTH'">
                <kopZklDalUcet>false</kopZklDalUcet>
                <!--                    DAL account-->
                <zklDalUcet>code:{$account/dAccount}</zklDalUcet>
            </xsl:if>
        </xsl:if>

        <xsl:variable name="vatAccount"
            select="document($journal_pohoda)/items/item[evidenceId = 29 and documentId = $documentId and xs:decimal(amount) = xs:decimal($priceVat) and starts-with(text, 'DPH')][1]"/>
        <xsl:choose>
            <xsl:when test="$vatAccount and $vatAccount != ''">
                <xsl:if test="$agendaType = 'PRIJEM' or $agendaType = 'BOTH'">
                    <kopDphMdUcet>false</kopDphMdUcet>
                    <dphMdUcet>code:{$vatAccount/mdAccount}</dphMdUcet>
                </xsl:if>

                <xsl:if test="$agendaType = 'VYDEJ' or $agendaType = 'BOTH'">
                    <kopDphDalUcet>false</kopDphDalUcet>
                    <dphDalUcet>code:{$vatAccount/dAccount}</dphDalUcet>
                </xsl:if>
            </xsl:when>

            <xsl:otherwise>
                <xsl:if test="number($priceVat)">
                    <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v
                        účetním deníku pro dokument s id {$documentId}, číslo
                        dokumentu:{$documentNumber} </xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
