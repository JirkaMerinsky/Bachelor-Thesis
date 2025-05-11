<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:ic="http://www.dcos.cz/flexi-migration/document-common"
>

    <xsl:include href="general/invoices-common.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>
    <xsl:param name="journal_pohoda"/>
    <xsl:param name="addressbook_pohoda"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:invoice">
        <!--        Input params for functions-->
        <xsl:param name="documentNumber" select="inv:invoiceHeader/inv:number/typ:numberRequested"/>
        <xsl:param name="documentId" select="inv:invoiceHeader/inv:id"/>
        <xsl:param name="agendaType">PRIJEM</xsl:param>
        <xsl:param name="accountingId"
                   select="'ext:POHODA:' || inv:invoiceHeader/inv:accounting/typ:id"/>
        <xsl:param name="agendaId">3</xsl:param>
        <xsl:variable name="vatRates">
            <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:priceLowVAT > 0">15</xsl:if>
            <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:price3VAT > 0">10</xsl:if>
            <xsl:if test="inv:invoiceSummary/*:homeCurrency/*:priceHighVAT > 0">21</xsl:if>
        </xsl:variable>

        <zavazek>
            <!--            Apply header template for all cases-->
            <xsl:apply-templates select="inv:invoiceHeader"/>
            <!--            Generate foreign currency if needed -->
            <xsl:if test="./*:invoiceSummary/*:foreignCurrency">
                <xsl:sequence select="ic:generateForeignCurrencyForInvoices(./*:invoiceSummary/*:foreignCurrency)"/>
            </xsl:if>
            <!--            Choose between detail and summary, base on the presence of the invoice detail-->
            <xsl:choose>
                <xsl:when test="inv:invoiceDetail">
                    <bezPolozek>false</bezPolozek>
                    <xsl:apply-templates select="inv:invoiceDetail"/>
                    <xsl:sequence
                      select="ic:generateAccountingForInvoiceFromAccountingId($accountingId, $account-assignment_flexi, $agendaType)"/>
                </xsl:when>
                <xsl:otherwise>
                    <bezPolozek>true</bezPolozek>
                    <xsl:apply-templates select="inv:invoiceSummary"/>
                    <xsl:sequence
                      select="ic:generateAccountingForInvoice($vatRates, $documentNumber, $accountingId, $documentId, $agendaType, $journal_pohoda, $agendaId, $account-assignment_flexi)"/>
                </xsl:otherwise>
            </xsl:choose>

        </zavazek>
    </xsl:template>

    <xsl:template match="inv:invoiceHeader">
        <!--        Call method to generate header invoice data-->
        <xsl:sequence select="ic:generateCommonInvoiceHeader($year, current(), $addressbook_pohoda)"/>
        <!--VAT Mapping generated from vat mapping file-->
        <xsl:sequence select="ic:insertVatMapping($vat-mapping, current())"/>
        <typDokl>code:OST. ZÁVAZKY</typDokl>
    </xsl:template>

    <xsl:template match="inv:invoiceDetail">
        <polozkyFaktury>
            <xsl:apply-templates select="inv:invoiceItem"/>
            <!--            TODO: doresit invoice advanced items-->
            <!--            <xsl:apply-templates select="inv:invoiceAdvancePaymentItem"/>-->
        </polozkyFaktury>
    </xsl:template>

    <xsl:template match="inv:invoiceItem">
        <xsl:param name="documentNumber" select="../../inv:invoiceHeader/inv:number/typ:numberRequested"/>
        <xsl:param name="documentId" select="../../inv:invoiceHeader/inv:id"/>
        <xsl:param name="agendaType">PRIJEM</xsl:param>
        <xsl:param name="agendaId">3</xsl:param>

        <zavazek-polozka>
            <xsl:sequence select="ic:generateCommonInvoiceItemWithoutAccounting($year, current(), false())"/>
            <xsl:sequence
              select="ic:generateAccountingForInvoiceItem($documentNumber, $documentId, current(), $agendaType, $journal_pohoda, $agendaId)"/>
        </zavazek-polozka>
    </xsl:template>

    <xsl:template match="inv:invoiceSummary">
        <xsl:sequence select="ic:generateCommonInvoiceSummary(current())"/>
    </xsl:template>

</xsl:stylesheet>
