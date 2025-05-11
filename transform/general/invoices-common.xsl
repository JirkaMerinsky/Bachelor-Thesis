<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.dcos.cz/flexi-migration/functions"
    xmlns:ic="http://www.dcos.cz/flexi-migration/document-common"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:itf="http://www.dcos.cz/flexi-migration/invoice-functions/invoice-item" version="3.0"
    expand-text="yes">
    <xsl:include href="invoice-functions/company-functions.xsl"/>
    <xsl:include href="invoice-functions/payment-type.xsl"/>
    <xsl:include href="invoice-functions/item-functions/invoice-item.xsl"/>
    <xsl:include href="invoice-functions/vat-map-function.xsl"/>
    <xsl:include href="invoice-functions/common-summary.xsl"/>
    <xsl:include href="invoice-functions/accounting-generation.xsl"/>
    <xsl:include href="invoice-functions/invoice-header.xsl"/>
    <xsl:function name="ic:insertVatMapping">
        <xsl:param name="vat-mapping"/>
        <xsl:param name="documentItem"/>
        <xsl:variable name="classificationVatCode" select="$documentItem/*:classificationVAT/*:ids"/>
        <xsl:sequence
            select="inf:vatMapFunction($vat-mapping, $documentItem, $classificationVatCode)"/>
    </xsl:function>
    <xsl:function name="ic:insertAccounts">
        <xsl:param name="accountingTypeIdsPohoda"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:for-each select="document($account-assignment_flexi)/winstrom/predpis-zauctovani">
            <xsl:if test="kod = upper-case($accountingTypeIdsPohoda)">
                <primUcet>{protiUcetPrijem}</primUcet>
                <protiUcet>{protiUcetVydej}</protiUcet>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>

    <xsl:function name="ic:generateCommonInvoiceHeader">
        <xsl:param name="year"/>
        <xsl:param name="invoiceHeader"/>
        <xsl:param name="addressbook"/>
        <!--        Assign the ID of invoice from POHODA + the year-->
        <id>{gi:generateId($invoiceHeader/*:id, $year, true(), false())}</id>
        <!--        Assign the code of invoice from POHODA-->
        <id>ext:POHODA:{$invoiceHeader/*:number/typ:numberRequested}</id>
        <xsl:sequence select="inf:header($year, $invoiceHeader, $addressbook)"/>

        <xsl:sequence
            select="inf:companyFuntion(document($addressbook)/*:responsePack/*:responsePackItem/*:listAddressBook, $invoiceHeader)"/>

        <xsl:sequence select="inf:paymentType($invoiceHeader/*:paymentType/typ:id)"/>

        <xsl:if test="
                $invoiceHeader/*:accounting and $invoiceHeader/*:accounting/typ:ids != 'Bez'
                and $invoiceHeader/*:accounting/typ:ids != 'Ručně'">
            <typUcOp>{gi:generateId($invoiceHeader/*:accounting/typ:id, $year, false(), false())}</typUcOp>
            
        </xsl:if>

        <!--        Strediska-->

    </xsl:function>
    <xsl:function name="ic:generateForeignCurrencyForInvoices">
        <xsl:param name="foreignCurrencyNode"/>
        <kurz>{$foreignCurrencyNode/typ:rate}</kurz>

        <mena>code:{upper-case($foreignCurrencyNode/typ:currency/typ:ids)}</mena>
        <kurzMnozstvi>1</kurzMnozstvi>
    </xsl:function>


    <xsl:function name="ic:generateCommonInvoiceItemWithoutAccounting">
        <xsl:param name="year"/>
        <xsl:param name="itemNode"/>
        <xsl:param name="isInvoice"/>
        <xsl:sequence select="itf:invoiceItem($year, $itemNode, $isInvoice)"/>

    </xsl:function>

    <xsl:function name="ic:generateAccountingForInvoiceItem">
        <xsl:param name="documentNumber"/>
        <xsl:param name="docId"/>
        <xsl:param name="itemNode"/>
        <xsl:param name="agendaType"/>
        <xsl:param name="journal_pohoda"/>
        <xsl:param name="agendaId"/>

        <xsl:sequence
            select="inf:invoiceItem($documentNumber, $docId, $itemNode, $agendaType, $journal_pohoda, $agendaId)"
        />
    </xsl:function>

    <xsl:function name="ic:generateCommonInvoiceSummary">
        <xsl:param name="invoiceSummary"/>
        <xsl:sequence select="inf:commonSummary($invoiceSummary)"/>
    </xsl:function>

    <xsl:function name="ic:generateAccountingForInvoice">
        <xsl:param name="vatRates"/>
        <xsl:param name="documentNumber"/>
        <xsl:param name="accountingId"/>
        <xsl:param name="docId"/>
        <xsl:param name="agendaType"/>
        <xsl:param name="journal_pohoda"/>
        <xsl:param name="agendaId"/>
        <xsl:param name="account-assignment_flexi"/>
        <!--        References the row in JOURNAL POHODA. Contains details about account-->

        <xsl:sequence
            select="inf:invoice($vatRates, $documentNumber, $accountingId, $docId, $agendaType, $journal_pohoda, $agendaId, $account-assignment_flexi)"
        />
    </xsl:function>

    <xsl:function name="ic:generateAccountingForInvoiceFromAccountingId">
        <xsl:param name="accountingId"/>
        <xsl:param name="account-assignment_flexi"/>
        <xsl:param name="agendaType"/>
        <xsl:sequence select="inf:invoiceById($accountingId, $account-assignment_flexi, $agendaType)"
        />
    </xsl:function>

</xsl:stylesheet>
