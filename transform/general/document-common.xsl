<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.dcos.cz/flexi-migration/functions"
                xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
>

    <xsl:import href="functions.xsl"/>
    <xsl:import href="variables.xsl"/>

    <xsl:function name="dc:generateDocumentSummary">
        <xsl:param name="docDetail"/>
        <xsl:param name="docSummary"/>
        <xsl:param name="docFictional"/>

        <xsl:choose>
            <xsl:when test="not($docDetail/*)">
                <bezPolozek>true</bezPolozek>
                <xsl:if test="$docSummary/*:foreignCurrency">
                    <mena>code:<xsl:value-of select="$docSummary/*:foreignCurrency/typ:currency/typ:ids"/>
                    </mena>
                    <xsl:choose>
                        <xsl:when test="not(xs:decimal($docSummary/*:foreignCurrency/typ:rate) = 0)">
                            <kurz>
                                <xsl:value-of
                                  select="f:validateAndTrimNumber($docSummary/*:foreignCurrency/typ:rate,19)"/>
                            </kurz>
                        </xsl:when>
                        <xsl:otherwise>
                            <stitky>exchange_rate_zero</stitky>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
                <sumOsv>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceNone,15)"/>
                </sumOsv>

                <sumZklSniz>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceLow,15)"/>
                </sumZklSniz>
                <sumZklSniz2>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:price3,15)"/>
                </sumZklSniz2>
                <sumZklZakl>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceHigh,15)"/>
                </sumZklZakl>

                <sumDphSniz>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceLowVAT,15)"/>
                </sumDphSniz>
                <sumDphSniz2>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:price3VAT,15)"/>
                </sumDphSniz2>
                <sumDphZakl>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceHighVAT,15)"/>
                </sumDphZakl>

                <sumCelkSniz>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceLowSum,15)"/>
                </sumCelkSniz>
                <sumCelkSniz2>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:price3Sum,15)"/>
                </sumCelkSniz2>
                <sumCelkZakl>
                    <xsl:value-of select="f:validateAndTrimNumber($docSummary/*:homeCurrency/typ:priceHighSum,15)"/>
                </sumCelkZakl>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$docSummary/*:foreignCurrency">
                    <mena>code:<xsl:value-of select="$docSummary/*:foreignCurrency/typ:currency/typ:ids"/>
                    </mena>
                    <xsl:choose>
                        <xsl:when test="not(xs:decimal($docSummary/*:foreignCurrency/typ:rate) = 0)">
                            <kurz>
                                <xsl:value-of
                                  select="f:validateAndTrimNumber($docSummary/*:foreignCurrency/typ:rate,19)"/>
                            </kurz>
                        </xsl:when>
                        <xsl:otherwise>
                            <stitky>exchange_rate_zero</stitky>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$docFictional = 'true'">
            <slevaDokl>100.00</slevaDokl>
        </xsl:if>

    </xsl:function>

    <!-- generates firma - partner identity -->
    <xsl:function name="dc:generatePartnerIdentity">
        <xsl:param name="partnerIdentity"/>
        <xsl:choose>
            <xsl:when test="$partnerIdentity/typ:id">
                <firma>ext:POHODA:<xsl:value-of select="f:textSubstring($partnerIdentity/typ:id,9)"/>
                </firma>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:company,255)"/>
                </nazFirmy>
                <ulice>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:street,255)"/>
                </ulice>
                <mesto>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:city,255)"/>
                </mesto>
                <psc>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:zip,20)"/>
                </psc>
                <ic>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:ico,20)"/>
                </ic>
                <dic>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:address/typ:dic,20)"/>
                </dic>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$partnerIdentity/typ:shipToAddress/typ:city/text()">
                <postovniShodna>false</postovniShodna>
                <faNazev>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:shipToAddress/typ:company,255)"/>
                </faNazev>
                <faNazev2>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:shipToAddress/typ:name,255)"/>
                </faNazev2>
                <faUlice>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:shipToAddress/typ:street,255)"/>
                </faUlice>
                <faMesto>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:shipToAddress/typ:city,255)"/>
                </faMesto>
                <faPsc>
                    <xsl:value-of select="f:textSubstring($partnerIdentity/typ:shipToAddress/typ:zip,20)"/>
                </faPsc>
            </xsl:when>
            <xsl:otherwise>
                <postovniShodna>true</postovniShodna>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Generates: id , kod, zamek, ucetni, account assignment, centre, activity, contract, note, currency etc.

    -->
    <xsl:function name="dc:generateCommonHeaderNodes">
        <xsl:param name="agendaId"/>
        <xsl:param name="documentHeader"/>
        <xsl:param name="docSummary"/>
        <xsl:param name="vat-mapping"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:param name="year"/>
        <!-- INCOMING, OUTGOING -->
        <xsl:param name="documentType"/>
        <xsl:param name="journalPohoda"/>

        <id>ext:POHODA:<xsl:value-of select="concat($documentHeader/*:id, '-', $year)"/>
        </id>
        <id>ext:POHODA:<xsl:value-of select="$documentHeader/*:number/typ:numberRequested"/>
        </id>

        <kod>
            <xsl:value-of select="f:textSubstring($documentHeader/*:number/typ:numberRequested,20)"/>
        </kod>
        <zamekK>
            <xsl:choose>
                <xsl:when test="$lock = 'open'">zamek.otevreno</xsl:when>
                <xsl:when test="$lock = 'viewable'">zamek.prohlednuto</xsl:when>
                <xsl:when test="$lock = 'halfLocked'">zamek.polozamceno</xsl:when>
                <xsl:when test="$lock = 'locked'">zamek.zamceno</xsl:when>
            </xsl:choose>
        </zamekK>

        <!-- if original document then origin  originalDocument else symVar -->
        <xsl:choose>
            <xsl:when test="$documentHeader/*:originalDocument and $documentHeader/*:originalDocument != ''">
                <cisDosle>
                    <xsl:value-of select="f:textSubstring($documentHeader/*:originalDocument,30)"/>
                </cisDosle>
            </xsl:when>
            <xsl:otherwise>
                <cisDosle>
                    <xsl:value-of select="f:textSubstring($documentHeader/*:symVar,30)"/>
                </cisDosle>
            </xsl:otherwise>
        </xsl:choose>
        <datVyst>
            <xsl:value-of select="f:validateDate($documentHeader/*:date)"/>
        </datVyst>
        <duzpPuv>
            <xsl:value-of select="f:validateDate($documentHeader/*:dateTax)"/>
        </duzpPuv>
        <xsl:choose>
            <xsl:when test="$documentHeader/*:symVar">
                <varSym>
                    <xsl:value-of select="f:textSubstring($documentHeader/*:symVar,30)"/>
                </varSym>
            </xsl:when>
            <xsl:otherwise>
                <varSym>nevyplněno</varSym>
            </xsl:otherwise>
        </xsl:choose>
        <datObj>
            <xsl:value-of select="f:validateDate($documentHeader/*:date)"/>
        </datObj><!-- TODO -->
        <ucetni>true</ucetni>

        <xsl:choose>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'delivery'">
                <formaUhradyCis>code:DOBIRKA</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'cash'">
                <formaUhradyCis>code:HOTOVE</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'creditcard'">
                <formaUhradyCis>code:KARTA</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'draft'">
                <formaUhradyCis>code:PREVOD</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'cheque'">
                <formaUhradyCis>code:SEK</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'postal'">
                <formaUhradyCis>code:SLOZENKA</formaUhradyCis>
            </xsl:when>
            <xsl:when test="$documentHeader/*:paymentType/typ:paymentType = 'compensation'">
                <formaUhradyCis>code:ZAPOCET</formaUhradyCis>
            </xsl:when>
        </xsl:choose>

        <!-- Which side will be a primary account based on document type (outgoing - income, incoming - expense) -->
        <xsl:variable name="replaceMode">
            <xsl:choose>
                <xsl:when test="$documentType='OUTGOING'">MD</xsl:when>
                <xsl:when test="$documentType='INCOMING'">D</xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$documentHeader/*:accounting/typ:id and
            $documentHeader/*:accounting/typ:id != 1 and
            not( $documentHeader/*:accounting/typ:accountingType = 'withoutAccounting')">

            <!-- select correct account assignement -->
            <xsl:variable name="typUcOp" select="concat('ext:POHODA:',$documentHeader/*:accounting/typ:id)"/>


            <xsl:variable name="accAssigment" as="node()*">
                <xsl:choose>
                    <xsl:when
                      test="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=concat($typUcOp,'-',$year)] and document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=concat($typUcOp,'-',$year)] != ''">
                        <xsl:sequence
                          select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=concat($typUcOp,'-',$year)]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence
                          select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=$typUcOp]"/>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <typUcOp>
                <xsl:value-of select="$accAssigment/id[starts-with(text(), 'ext:POHODA:')]/text()"/>
            </typUcOp>

            <!-- Which vat rates should be set on document -->
            <xsl:variable name="vatRates">
                <xsl:if test="$docSummary/*:homeCurrency/*:priceLowVAT > 0">15</xsl:if>
                <xsl:if test="$docSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
                <xsl:if test="$docSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
            </xsl:variable>

            <!-- set correct accounting based on journal not account assignment -->
            <xsl:sequence
              select="dc:validateAndUpdateAccountingOnDocument($agendaId, $documentHeader/*:id, $documentHeader/*:number/typ:numberRequested ,$replaceMode, $journalPohoda, $accAssigment, $vatRates, $documentHeader/*:date , $year)"/>
        </xsl:if>

        <xsl:if test="$documentHeader/*:accounting/typ:id =  '1'">
            <xsl:sequence
              select="dc:validateAndUpdateAccountingOnDocument($agendaId, $documentHeader/*:id, $documentHeader/*:number/typ:numberRequested ,$replaceMode, $journalPohoda, '', '', $documentHeader/*:date , $year)"/>
        </xsl:if>

        <xsl:variable name="classificationVatCode" select="$documentHeader/*:classificationVAT/*:ids"/>
        <xsl:for-each select="document($vat-mapping)/items/item">
            <xsl:if test="Pohoda_zkratka = $classificationVatCode">
                <clenDph>code:<xsl:value-of select="Flexy_radky_dph_zkratka"/>
                </clenDph>

                <xsl:if test="Flexi_radky_khdph_zkratka/node()">
                    <clenKonVykDph>code:<xsl:value-of select="Flexi_radky_khdph_zkratka"/>
                    </clenKonVykDph>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>

        <xsl:choose>
            <xsl:when test="$documentHeader/*:centre">
                <stredisko>code:<xsl:value-of select="upper-case($documentHeader/*:centre/typ:ids)"/>
                </stredisko>
            </xsl:when>
            <xsl:otherwise>
                <stredisko>code:C</stredisko>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$documentHeader/*:contract/typ:ids">
            <zakazka>code:<xsl:value-of select="upper-case($documentHeader/*:contract/typ:ids)"/>
            </zakazka>
        </xsl:if>
        <xsl:if test="$documentHeader/*:activity/typ:ids">
            <cinnost>code:<xsl:value-of select="upper-case($documentHeader/*:activity/typ:ids)"/>
            </cinnost>
        </xsl:if>

        <xsl:choose>
            <xsl:when test="$docSummary/*:foreignCurrency">
                <mena>code:<xsl:value-of select="$docSummary/*:foreignCurrency/typ:currency/typ:ids"/>
                </mena>
            </xsl:when>
            <xsl:otherwise>
                <mena>code:CZK</mena>
            </xsl:otherwise>
        </xsl:choose>

        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>
        <poznam>
            <xsl:value-of select="$documentHeader/*:note"/>
        </poznam>

        <xsl:sequence select="dc:generatePartnerIdentity($documentHeader/*:partnerIdentity)"/>

    </xsl:function>


    <!--
         Common item notes
    -->
    <xsl:function name="dc:generateCommonItemNodes">
        <xsl:param name="agendaId"/>
        <xsl:param name="documentId"/>
        <xsl:param name="documentItem"/>
        <xsl:param name="docSummary"/>
        <xsl:param name="vat-mapping"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:param name="year"/>
        <xsl:param name="journalPohoda"/>
        <xsl:param name="replaceMode"/>
        <xsl:param name="documentAccounting"/>
        <xsl:param name="documentNumber"/>
        <xsl:param name="documentDate"/>

        <kod>
            <xsl:value-of select="f:textSubstring($documentItem/*:code,20)"/>
        </kod>
        <nazev>
            <xsl:value-of select="f:textSubstring($documentItem/*:text,255)"/>
        </nazev>


        <xsl:variable name="manualAccounting" select="$documentAccounting/typ:id =  '1'"/>

        <xsl:variable name="classificationVatCode" select="$documentItem/*:classificationVAT/*:ids"/>
        <xsl:for-each select="document($vat-mapping)/items/item">
            <xsl:if test="Pohoda_zkratka = $classificationVatCode">
                <clenDph>code:<xsl:value-of select="f:textSubstring(Flexy_radky_dph_zkratka,15)"/>
                </clenDph>
                <kopClenDph>false</kopClenDph>

                <xsl:if test="Flexi_radky_khdph_zkratka/node()">
                    <clenKonVykDph>code:<xsl:value-of select="f:textSubstring(Flexi_radky_khdph_zkratka,15)"/>
                    </clenKonVykDph>
                    <kopClenKonVykDph>false</kopClenKonVykDph>
                </xsl:if>

                <xsl:if test="Pdp/node()">
                    <dphPren>code:<xsl:value-of select="Pdp"/>
                    </dphPren>
                </xsl:if>
            </xsl:if>

        </xsl:for-each>

        <!-- if there is an accounting on the item, then find correct account assigment -->
        <xsl:if test="($documentItem/*:accounting/typ:id and
                $documentItem/*:accounting/typ:id != 1 and
                not( $documentItem/*:accounting/typ:accountingType = 'withoutAccounting'))">

            <!-- select correct account assignement -->
            <xsl:variable name="typUcOp" select="concat('ext:POHODA:',$documentItem/*:accounting/typ:id)"/>
            <xsl:variable name="assignmentYear"
                          select="document($account-assignment_flexi)/winstrom/predpis-zauctovani[id=concat($typUcOp,'-',$year)]"/>

            <xsl:choose>
                <xsl:when test="$assignmentYear and $assignmentYear != ''">
                    <typUcOp>
                        <xsl:value-of select="concat($typUcOp,'-',$year)"/>
                    </typUcOp>
                </xsl:when>
                <xsl:otherwise>
                    <typUcOp>
                        <xsl:value-of select="$typUcOp"/>
                    </typUcOp>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- if there is an account assignment on the item or the whole document is manually accounted then try to set MD/D from the Ledger -->
        <xsl:if test="(($documentItem/*:accounting/typ:id and
                    $documentItem/*:accounting/typ:id != 1 and
                    not( $documentItem/*:accounting/typ:accountingType = 'withoutAccounting') or string($manualAccounting) = 'true')) and $ledger_primary_document_source = 'false'">

            <xsl:sequence
              select="dc:validateAndUpdateAccountingOnItem($agendaId, $documentId, $documentItem,$replaceMode, $journalPohoda , $documentNumber, $documentDate, $year)"/>
        </xsl:if>

        <xsl:choose>
            <xsl:when
              test="$ledger_primary_document_source = 'true' and not( $documentAccounting/typ:accountingType =  'withoutAccounting')">
                <slevaPol>
                    <xsl:value-of select="100"/>
                </slevaPol>
                <uplSlevaDokl>false</uplSlevaDokl>
            </xsl:when>

            <xsl:otherwise>
                <slevaPol>
                    <xsl:value-of select="$documentItem/*:discountPercentage"/>
                </slevaPol>
                <uplSlevaDokl>false</uplSlevaDokl>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$documentItem/*:code">
                <cenik>code:<xsl:value-of select="f:textSubstring(upper-case($documentItem/*:code), 25)"/>
                </cenik>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$documentItem/*:centre">
            <stredisko>code:<xsl:value-of select="f:textSubstring(upper-case($documentItem/*:centre/typ:ids),15)"/>
            </stredisko>
            <kopStred>false</kopStred>
        </xsl:if>
        <xsl:if test="$documentItem/*:activity/typ:ids">
            <cinnost>code:<xsl:value-of select="f:textSubstring(upper-case($documentItem/*:activity/typ:ids),15)"/>
            </cinnost>
            <kopCinnost>false</kopCinnost>
        </xsl:if>

        <poznam>
            <xsl:value-of select="$documentItem/*:note"/>
        </poznam>

        <xsl:choose>
            <xsl:when test="$documentItem/*:payVAT ='true'">
                <typCenyDphK>typCeny.sDph</typCenyDphK>
            </xsl:when>
            <xsl:otherwise>
                <typCenyDphK>typCeny.bezDph</typCenyDphK>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$documentItem/*:rateVAT ='third'">
                <typSzbDphK>typSzbDph.dphSniz2</typSzbDphK>
            </xsl:when>
            <xsl:when test="$documentItem/*:rateVAT ='low'">
                <typSzbDphK>typSzbDph.dphSniz</typSzbDphK>
            </xsl:when>
            <xsl:when test="$documentItem/*:rateVAT ='high'">
                <typSzbDphK>typSzbDph.dphZakl</typSzbDphK>
            </xsl:when>
            <xsl:when test="$documentItem/*:rateVAT ='none'">
                <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$documentItem/*:quantity = 0.0">
                <typPolozkyK>typPolozky.ucetni</typPolozkyK>
            </xsl:when>
            <xsl:when test="$documentItem/*:code">
                <typPolozkyK>typPolozky.katalog</typPolozkyK>
            </xsl:when>
            <xsl:otherwise>
                <typPolozkyK>typPolozky.obecny</typPolozkyK>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$documentItem/*:stockItem/typ:store">
                <sklad>ext:POHODA:<xsl:value-of select="f:textSubstring($documentItem/*:stockItem/typ:store/typ:id,9)"/>
                </sklad>
            </xsl:when>
        </xsl:choose>

        <xsl:choose>
            <xsl:when test="$documentItem/*:rateVAT = 'third'">
                <szbDph>10.0</szbDph>
            </xsl:when>
            <xsl:when test="$documentItem/*:rateVAT = 'low'">
                <szbDph>15.0</szbDph>
            </xsl:when>
            <xsl:when test="$documentItem/*:rateVAT = 'high'">
                <szbDph>21.0</szbDph>
            </xsl:when>
            <xsl:otherwise>
                <szbDph>0.0</szbDph>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$documentItem/*:foreignCurrency and  $docSummary/*:foreignCurrency">
                <cenaMj>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:foreignCurrency/typ:unitPrice,19)"/>
                </cenaMj>
                <sumZklMen>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:foreignCurrency/typ:price,15)"/>
                </sumZklMen>
                <sumDphMen>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:foreignCurrency/typ:priceVAT,15)"/>
                </sumDphMen>
                <sumCelkemMen>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:foreignCurrency/typ:priceSum,15)"/>
                </sumCelkemMen>
            </xsl:when>
            <xsl:otherwise>
                <cenaMj>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:homeCurrency/typ:unitPrice,19)"/>
                </cenaMj>
                <sumZkl>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:homeCurrency/typ:price,15)"/>
                </sumZkl>
                <sumDph>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:homeCurrency/typ:priceVAT,15)"/>
                </sumDph>
                <sumCelkem>
                    <xsl:value-of select="f:validateAndTrimNumber($documentItem/*:homeCurrency/typ:priceSum,15)"/>
                </sumCelkem>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <!--/**
         /**
         * Validates and updates accounting on document based on Journal (account assignement seems to be faulty)
         *
         * @param documentNumber   unique number of document (number requested)
         * @param agendaFirstLetterUpperCase evidence first letter name (e.g. Prijate faktury - P)
         * @param replaceMode    Which side will be used as a primUcet, Replace mode on document is inverted to replace mode on the item
         * @param journalPohoda   path to journal in pohoda format
         * @param manualAccounting - if true then protiucet and dph ucet will not be filled out (only the primary)
         * @param vatRates - if filled out and manual_accounting is false then dphUcet is filled out  (21, 15 ,10)
         */
         * -->
    <xsl:function name="dc:validateAndUpdateAccountingOnDocument">

        <xsl:param name="agendaId"/>
        <xsl:param name="documentId"/>
        <xsl:param name="documentNumber"/>
        <xsl:param name="replaceMode"/>
        <xsl:param name="journalPohoda"/>
        <xsl:param name="accountAssignment"/>
        <xsl:param name="vatRates"/>
        <xsl:param name="documentDate"/>
        <xsl:param name="year"/>

        <xsl:variable name="account"
                      select="document($journalPohoda)/items/item[evidenceId = $agendaId and documentId = $documentId and not(starts-with(text/text(), 'DPH'))][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:if test="$replaceMode = 'MD'">
                    <primUcet>code:<xsl:value-of select="$account/mdAccount"/>
                    </primUcet>
                    <xsl:if test="not($accountAssignment ='')">
                        <protiUcet>code:<xsl:value-of select="$account/dAccount"/>
                        </protiUcet>

                        <!-- fill out vat accounting as well -->
                        <xsl:if test="$vatRates != ''">
                            <xsl:variable name="vatAccount"
                                          select="document($journalPohoda)/items/item[evidenceId = $agendaId and documentId = $documentId and starts-with(text/text(), 'DPH')][1]"/>

                            <xsl:choose>
                                <xsl:when test="$vatAccount and $vatAccount != ''">
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
                                </xsl:when>

                                <xsl:otherwise>
                                    <xsl:if test="substring($documentDate ,0,  5) = $year">
                                        <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v
                                            účetním deníku pro dokument s id <xsl:value-of select="$documentId"/>, číslo
                                            dokumentu:
                                            <xsl:value-of select="$documentNumber"/>
                                        </xsl:message>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
                <!-- INCOMING DOCUMENT -->
                <xsl:if test="$replaceMode = 'D'">
                    <primUcet>code:<xsl:value-of select="$account/dAccount"/>
                    </primUcet>
                    <xsl:if test="not($accountAssignment ='')">
                        <protiUcet>code:<xsl:value-of select="$account/mdAccount"/>
                        </protiUcet>
                        <!-- fill out vat accounting as well -->
                        <xsl:if test="$vatRates != ''">
                            <xsl:variable name="vatAccount"
                                          select="document($journalPohoda)/items/item[evidenceId = $agendaId and documentId = $documentId and starts-with(text/text(), 'DPH')][1]"/>
                            <xsl:choose>
                                <xsl:when test="$vatAccount and $vatAccount != ''">
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
                                    <xsl:if test="substring($documentDate ,0,  5) = $year">
                                        <xsl:message>ACC_PROBLEM: Záučtovaní DPH dokladu neproběhlo. Nenalezen záznam v
                                            účetním deníku pro dokument s id <xsl:value-of select="$documentId"/>, číslo
                                            dokumentu:
                                            <xsl:value-of select="$documentNumber"/>
                                        </xsl:message>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$accountAssignment and not($accountAssignment ='')">
                        <xsl:if test="$replaceMode = 'MD'">
                            <primUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                            </primUcet>
                            <protiUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                            </protiUcet>

                        </xsl:if>
                        <!-- INCOMING DOCUMENT -->
                        <xsl:if test="$replaceMode = 'D'">
                            <primUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetPrijem/text()"/>
                            </primUcet>
                            <protiUcet>
                                <xsl:value-of select="$accountAssignment/protiUcetVydej/text()"/>
                            </protiUcet>
                        </xsl:if>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:if test="substring($documentDate ,0,  5) = $year">
                            <xsl:message>ACC_PROBLEM: Záučtovaní dokladu neproběhlo. Nenalezen záznam v účetním deníku
                                pro dokument s id <xsl:value-of select="$documentId"/>, číslo dokumentu:
                                <xsl:value-of select="$documentNumber"/>
                            </xsl:message>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="dc:validateAndUpdateAccountingOnItem">

        <xsl:param name="agendaId"/>
        <xsl:param name="documentId"/>
        <xsl:param name="documentItem"/>
        <xsl:param name="replaceMode"/>
        <xsl:param name="journalPohoda"/>
        <xsl:param name="documentNumber"/>
        <xsl:param name="documentDate"/>
        <xsl:param name="year"/>

        <xsl:variable name="price">
            <xsl:value-of select="$documentItem/*:homeCurrency/typ:price"/>
        </xsl:variable>
        <xsl:variable name="priceVat">
            <xsl:value-of select="$documentItem/*:homeCurrency/typ:priceVAT"/>
        </xsl:variable>

        <xsl:variable name="account"
                      select="document($journalPohoda)/items/item[evidenceId = $agendaId and documentId = $documentId and not(starts-with(text/text(), 'DPH')) and xs:decimal(amount) = xs:decimal($price)][1]"/>

        <xsl:choose>
            <xsl:when test="$account and $account != ''">
                <xsl:if test="$replaceMode = 'MD' or $replaceMode = 'BOTH'">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <zklMdUcet>code:<xsl:value-of select="$account/mdAccount"/>
                    </zklMdUcet>
                </xsl:if>

                <xsl:if test="$replaceMode = 'D' or $replaceMode = 'BOTH'">
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <zklDalUcet>code:<xsl:value-of select="$account/dAccount"/>
                    </zklDalUcet>
                </xsl:if>

                <xsl:variable name="vatAccount"
                              select="document($journalPohoda)/items/item[evidenceId = $agendaId and documentId = $documentId and starts-with(text/text(), 'DPH') and xs:decimal(amount) = xs:decimal($priceVat)][1]"/>


                <xsl:choose>
                    <xsl:when test="$vatAccount and $vatAccount != ''">
                        <xsl:if test="$replaceMode = 'MD' or $replaceMode = 'BOTH'">
                            <kopDphMdUcet>false</kopDphMdUcet>
                            <dphMdUcet>code:<xsl:value-of select="$vatAccount/mdAccount"/>
                            </dphMdUcet>
                        </xsl:if>
                        <!-- OUTGOING DOCUMENT - revenue - MD - is usually read only -->
                        <xsl:if test="$replaceMode = 'D' or $replaceMode = 'BOTH'">
                            <kopDphDalUcet>false</kopDphDalUcet>
                            <dphDalUcet>code:<xsl:value-of select="$vatAccount/dAccount"/>
                            </dphDalUcet>
                        </xsl:if>
                    </xsl:when>

                    <!-- accounting for VAT not found in ledger but it should be -->
                    <xsl:when test="xs:decimal($priceVat) >  0">
                        <xsl:if test="substring($documentDate ,0,  5) = $year">
                            <xsl:message>ACC_PROBLEM: Záučtovaní DPH položky neproběhlo. Nenalezen záznam v účetním
                                deníku pro dokument s id <xsl:value-of select="$documentId"/>. Název položky:
                                <xsl:value-of select="$documentItem/*:text"/>, číslo dokumentu:
                                <xsl:value-of select="$documentNumber"/>
                            </xsl:message>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <!-- accounting not found in ledger -->
            <xsl:otherwise>
                <xsl:if test="substring($documentDate ,0,  5) = $year">
                    <xsl:message>ACC_PROBLEM: Záučtovaní položky neproběhlo. Nenalezen záznam v účetním deníku pro
                        dokument s id <xsl:value-of select="$documentId"/>. Název položky:
                        <xsl:value-of select="$documentItem/*:text"/> , číslo dokumentu:
                        <xsl:value-of select="$documentNumber"/>
                    </xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


    <!-- document number e.g. invoice number, agendaFirstLetterUpperCase - e.g. V - vydane faktury, elementItemName - e.g. intDocItem, replaceMode -  whether to replace M, MD, or both items - M, MD, BOTH   -->
    <xsl:function name="dc:generateAccountingItem">
        <xsl:param name="documentId"/>
        <xsl:param name="evidenceId"/>
        <xsl:param name="elementItemName"/>
        <xsl:param name="replaceMode"/>
        <xsl:param name="journal_pohoda"/>
        <xsl:param name="vat-mapping"/>
        <xsl:param name="classificationVatCode"/>

        <xsl:for-each select="document($journal_pohoda)/items/item">

            <xsl:if test="documentId=$documentId and evidenceId = $evidenceId">
                <xsl:element name="{$elementItemName}">
                    <ucetni>true</ucetni>
                    <nazev>
                        <xsl:value-of select="text"/>
                    </nazev>
                    <poznam>Zaúčtovano ručně z Pohody, id záznamu #<xsl:value-of select="id"/>
                    </poznam>
                    <typPolozkyK showAs="Položka pro zaúčtování">typPolozky.ucetni</typPolozkyK>
                    <cenaMj>
                        <xsl:value-of select="f:validateAndTrimNumber(amount,19)"/>
                    </cenaMj>
                    <mnozMj>1.0</mnozMj>
                    <mena>code:CZK</mena>
                    <!-- TODO: HOW IT WILL WORK IN ES -->
                    <szbDph>0.0</szbDph>

                    <xsl:if test="$vat-mapping != ''">
                        <xsl:for-each select="document($vat-mapping)/items/item">
                            <xsl:if test="Pohoda_zkratka = $classificationVatCode">
                                <xsl:if test="Pdp/node()">
                                    <dphPren>code:<xsl:value-of select="Pdp"/>
                                    </dphPren>
                                </xsl:if>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>

                    <xsl:if test="$replaceMode = 'MD' or $replaceMode = 'BOTH'">
                        <zklMdUcet>code:<xsl:value-of select="mdAccount"/>
                        </zklMdUcet>
                        <kopZklMdUcet>false</kopZklMdUcet>
                    </xsl:if>

                    <xsl:if test="$replaceMode = 'D' or $replaceMode = 'BOTH'">
                        <kopZklDalUcet>false</kopZklDalUcet>
                        <zklDalUcet>code:<xsl:value-of select="dAccount"/>
                        </zklDalUcet>
                    </xsl:if>
                    <sumCelkem>
                        <xsl:value-of select="f:validateAndTrimNumber(amount,15)"/>
                    </sumCelkem>

                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="dc:validateDocumentSum">
        <xsl:param name="documentNumber"/>
        <xsl:param name="newItems"/>
        <xsl:param name="documentSummary"/>

        <xsl:variable name="newItemsSum">
            <xsl:value-of select="sum($newItems/sumCelkem)"/>
        </xsl:variable>


        <xsl:variable name="documentSummarySum">
            <xsl:value-of
              select="sum($documentSummary/*:homeCurrency/typ:priceNone[. != '']) + sum($documentSummary/*:homeCurrency/typ:priceLow[. != '']) + sum($documentSummary/*:homeCurrency/typ:priceHigh[. != '']) + sum($documentSummary/*:homeCurrency/typ:price3[. != ''] )"/>
        </xsl:variable>
        <xsl:variable name="documentSummarySumVat">
            <xsl:value-of
              select="sum($documentSummary/*:homeCurrency/typ:priceLowVAT[. != '']) + sum($documentSummary/*:homeCurrency/typ:priceHighVAT[. != '']) + sum($documentSummary/*:homeCurrency/typ:price3VAT[. != ''] )"/>
        </xsl:variable>
        <xsl:variable name="documentSum">
            <xsl:value-of select="xs:double($documentSummarySum) + xs:double($documentSummarySumVat) "/>
        </xsl:variable>
        <xsl:if test="(xs:double($documentSum) - xs:double($newItemsSum)) &gt; 1">
            <xsl:message>ACC_PROBLEM: Suma základu dokladu nesedí s účetním deníkem pro dokument s číslem:
                <xsl:value-of select="$documentNumber"/>
            </xsl:message>
        </xsl:if>
    </xsl:function>


    <xsl:function name="dc:insertVatMapping">
        <!--        Vat mapping file for selected company-->
        <xsl:param name="vat-mapping"/>
        <!--        Document header section of xml. For example: prijate-faktury = inv:invoiceHeader-->
        <xsl:param name="documentItem"/>
        <!--        Use wildcard '*' to have generic method, reusable for all agendas-->
        <xsl:variable name="classificationVatCode" select="$documentItem/*:classificationVAT/*:ids"/>
        <!--        Iterate through the Vat mapping file to find correct "data"-->
        <xsl:for-each select="document($vat-mapping)/items/item">
            <xsl:if test="Pohoda_zkratka = $classificationVatCode">
                <!--                Assign 'clenDph' = radky DPH. Use code reference-->
                <clenDph>code:<xsl:value-of select="f:textSubstring(Flexi_radky_dph_zkratka,15)"/>
                </clenDph>
                <!--                 Copy the row of the DPH = false-->
                <kopClenDph>false</kopClenDph>

                <!--                Assing 'clenKonVykDph' = radky kontrolniho hlaseni. Use code reference-->
                <xsl:if test="Flexi_radky_khdph_zkratka/node()">
                    <clenKonVykDph>code:<xsl:value-of select="f:textSubstring(Flexi_radky_khdph_zkratka,15)"/>
                    </clenKonVykDph>
                    <!--                    Copy the row of the KH_DPH = false -->
                    <kopClenKonVykDph>false</kopClenKonVykDph>
                </xsl:if>

                <!--                Assign 'dphPren' = preneseni DPH. Not used in our application now -->
                <xsl:if test="Pdp/node()">
                    <dphPren>code:<xsl:value-of select="Pdp"/>
                    </dphPren>
                </xsl:if>
            </xsl:if>

        </xsl:for-each>


    </xsl:function>
    <xsl:function name="dc:insertAccounts">
        <xsl:param name="accountingTypeIdsPohoda"/>
        <xsl:param name="account-assignment_flexi"/>

        <xsl:for-each select="document($account-assignment_flexi)/winstrom/predpis-zauctovani">
            <xsl:variable name="accountingTypeIdsAbra">
                <xsl:value-of select="kod"/>
            </xsl:variable>

            <xsl:if test="$accountingTypeIdsAbra = upper-case($accountingTypeIdsPohoda)">
                <primUcet>
                    <xsl:value-of select="protiUcetPrijem"/>
                </primUcet>
                <protiUcet>
                    <xsl:value-of select="protiUcetVydej"/>
                </protiUcet>
            </xsl:if>

        </xsl:for-each>
    </xsl:function>
</xsl:stylesheet>