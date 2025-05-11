<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:param name="year"/>
    <xsl:param name="issued-invoice_flexi"/>
    <xsl:param name="received-invoice_flexi"/>
    <xsl:param name="other-debt_flexi"/>
    <xsl:param name="other-obligation_flexi"/>
    <xsl:param name="internal-document_flexi"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:listInvoice">
        <!--        Group by document number = bank document ID ususally -->
        <xsl:for-each-group select="lst:invoice/inv:liquidations/typ:liquidation"
            group-by="typ:sourceDocument/typ:id">

            <!--            TODO: possible to filter in for each group? To delete this extra if statement-->
            <xsl:if test="current-group()/typ:sourceAgenda = 'bank'">
                <banka>
                    <!--                Fill the ID of the bank with external reference -->
                    <id>{gi:generateId(current-grouping-key(), $year, true(), false())}</id>
                    <sparovani>
                        <!--            Iterate over the group and for each create SPAROVANI-->
                        <xsl:for-each select="current-group()">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </sparovani>
                </banka>
            </xsl:if>

        </xsl:for-each-group>
    </xsl:template>

    <xsl:template match="typ:liquidation">
        <xsl:param name="liqSum" select="typ:foreignCurrencySource"/>
        <xsl:param name="invoiceSum">
            <xsl:if test="../../inv:invoiceSummary/inv:foreignCurrency"
                >{../../inv:invoiceSummary/inv:foreignCurrency/typ:priceSum}</xsl:if>
            <xsl:if test="not(../../inv:invoiceSummary/inv:foreignCurrency)">
                <xsl:choose>
                    <xsl:when test="../../inv:invoiceSummary/inv:homeCurrency/typ:priceNone != 0"
                        >{../../inv:invoiceSummary/inv:homeCurrency/typ:priceNone}</xsl:when>
                    <xsl:when test="../../inv:invoiceSummary/inv:homeCurrency/typ:priceLowSum != 0"
                        >{../../inv:invoiceSummary/inv:homeCurrency/typ:priceLowSum}</xsl:when>
                    <xsl:when test="../../inv:invoiceSummary/inv:homeCurrency/typ:priceHighSum != 0"
                        >{../../inv:invoiceSummary/inv:homeCurrency/typ:priceHighSum}</xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:param>


        <!--                in case the "castka" is not fill it will take whole remaining sum as "castka"-->
        <uhrazovanaFak>
            <!--                Castka attribute-->

            <!--
                    TODO: Asi bude potreba kouknout a porovna cenu likvidace a cenu celkove faktury, pokud jsou shodne, tak nemusim castku davat
                    TODO: pokud nejsou shodne, tak kouknout do bankovniho dokumentu a porovnat cenu, a kdyztak tu cenu vzit z bankovniho dokementu, pro vyhnuti se exception pri REST callu na flexi
                    -->
            <xsl:if test="$liqSum != $invoiceSum">
                <xsl:attribute name="castka">
                    <!--                TODO: attempt to "floor" the amount and change to integer, because of frequent issue with getting over the price-->
                    <xsl:value-of select="typ:foreignCurrencySource"/>
                </xsl:attribute>
            </xsl:if>
            <!--                Type attribute-->
            <xsl:attribute name="type">
                <xsl:if test="../../inv:invoiceHeader/inv:invoiceType = 'receivedInvoice'"
                    >faktura-prijata</xsl:if>
                <xsl:if test="../../inv:invoiceHeader/inv:invoiceType = 'issuedInvoice'"
                    >faktura-vydana</xsl:if>
                <xsl:if test="../../inv:invoiceHeader/inv:invoiceType = 'receivable'"
                    >pohledavka</xsl:if>
                <xsl:if test="../../inv:invoiceHeader/inv:invoiceType = 'commitment'"
                    >zavazek</xsl:if>
            </xsl:attribute>
            <!--                        Invoice ID referenced by external ID (ext:POHODA:{ID})-->            
            <id>{gi:generateId(../../inv:invoiceHeader/inv:id, $year, true(), false())}</id>
        </uhrazovanaFak>
        <zbytek>castecnaUhradaNeboIgnorovat</zbytek>
        <!--        ZBYTEK EXPLANATIONS
        ne: zbytek nesmí nastat; pokud k němu dojde, jedná se o chybu
        zauctovat: zbytek se zaúčtuje
        ignorovat: zbytek se ignoruje
        castecnaUhrada: pokud je částka na uhrazujícím dokladu menší než na uhrazovaném, jedná se o částečnou úhradu
        castecnaUhradaNeboZauctovat: pokud je částka na uhrazujícím dokladu větší než na uhrazovaném, zbytek se zaúčtuje; pokud je menší, jedná se o částečnou úhradu
        castecnaUhradaNeboIgnorovat: pokud je částka na uhrazujícím dokladu větší než na uhrazovaném, zbytek se ignoruje; pokud je menší, jedná se o částečnou úhradu
        -->
    </xsl:template>

</xsl:stylesheet>
