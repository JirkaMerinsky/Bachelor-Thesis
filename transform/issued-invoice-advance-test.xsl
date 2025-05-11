<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
    xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/document-common.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="account-assignment_flexi"/>
    <xsl:param name="year"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:invoice[(inv:invoiceDetail)]">
        <faktura-vydana>
            <bezPolozek>false</bezPolozek>
            <xsl:apply-templates select="inv:invoiceHeader"/>
            <xsl:apply-templates select="inv:invoiceDetail"/>
            <xsl:if test="inv:invoiceSummary/inv:foreignCurrency">
                <mena>code:{upper-case(inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids)}</mena>
                <kurz>{inv:foreignCurrency/typ:rate}</kurz>
            </xsl:if>

        </faktura-vydana>
    </xsl:template>
    <!--    Případ, ve kterém fakture neobsahuje detail, tudíž ani položky-->
    <xsl:template match="lst:invoice[not(inv:invoiceDetail)]">
        <faktura-vydana>
            <bezPolozek>true</bezPolozek>
            <xsl:apply-templates select="inv:invoiceHeader"/>
            <xsl:apply-templates select="inv:invoiceSummary"/>
            <xsl:if test="inv:invoiceSummary/inv:foreignCurrency">
                <mena>code:{upper-case(inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids)}</mena>
                <kurz>{inv:foreignCurrency/typ:rate}</kurz>
            </xsl:if>
        </faktura-vydana>
    </xsl:template>

    <xsl:template match="inv:invoiceHeader">
        <!--        Při nepřevádění číselných řad:-->
        <typDokl>code:ZÁLOHA</typDokl>
        <!--        Při převádění číselných řad:-->
        <id>{gi:generateId(inv:id, $year, true(), false())}</id>
        <zbyvaUhraditMen>0</zbyvaUhraditMen>
        <kod>{inv:number/typ:numberRequested}</kod>
        <cisDosle>{if (inv:originalDocument) then inv:originalDocument else inv:symVar}</cisDosle>
        <varSym>{inv:symVar}</varSym>
        <datVyst>{inv:date}</datVyst>
        <datSazbyDph>{inv:dateTax}</datSazbyDph>
        <datTermin>{inv:dateDue}</datTermin>
        <datSplat>{inv:dateDue}</datSplat>
        <xsl:if test="inv:contract">
            <zakazka>code:{upper-case(inv:contract/typ:ids)}</zakazka>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="inv:dateKHDPH">
                <duzpUcto>{inv:dateTax}</duzpUcto>
                <duzpPuv>{inv:dateKHDPH}</duzpPuv>
            </xsl:when>
            <xsl:otherwise>
                <duzpUcto>{inv:dateAccounting}</duzpUcto>
                <duzpPuv>{inv:dateTax}</duzpPuv>
            </xsl:otherwise>
        </xsl:choose>
        <popis>{inv:text}</popis>

        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>

        <xsl:choose>
            <xsl:when test="inv:partnerIdentity/typ:id">
                <firma>ext:POHODA:{inv:partnerIdentity/typ:id}</firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="adresaFirmy"/>
            </xsl:otherwise>
        </xsl:choose>
        <!--        TODO: nefunguje spravne, formy uhrady musime importovat sami pokud tohle chceme pouzivat, ale neni to defaultni nastaveni, napriklad ONE3D nema ani ID = 9-->
        <formaUhradyCis>
            <xsl:choose>
                <xsl:when test="inv:paymentType/typ:ids = 'Příkazem'">3</xsl:when>
                <xsl:when test="inv:paymentType/typ:ids = 'Hotově'">1</xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </formaUhradyCis>

        <!--        accounting from ID instead of IDS -->
        <xsl:if
            test="inv:accounting and inv:accounting/typ:ids != 'Bez' and inv:accounting/typ:ids != 'Ručně'">
            <typUcOp>ext:POHODA:{inv:accounting/typ:id}</typUcOp>
        </xsl:if>

        <xsl:if test="inv:centre/typ:ids">
            <stredisko>code:{upper-case(inv:centre/typ:ids)}</stredisko>
        </xsl:if>
        <xsl:if test="inv:activity/typ:ids">
            <cinnost>code:{upper-case(inv:activity/typ:ids)}</cinnost>
        </xsl:if>


        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>

        <!--        TODO: not use for now. Have to change for ID instead of IDS-->
        <!--        <xsl:variable name="idsPath">-->
        <!--            <xsl:value-of select="inv:accounting/typ:ids"/>-->
        <!--        </xsl:variable>-->
        <!--        <xsl:sequence select="dc:insertAccounts($idsPath, $account-assignment_flexi)"/>-->

    </xsl:template>

    <xsl:template match="inv:invoiceDetail">
        <polozkyFaktury>
            <xsl:apply-templates select="inv:invoiceItem"/>
        </polozkyFaktury>
    </xsl:template>

    <xsl:template match="inv:invoiceItem">
        <faktura-vydana-polozka>
            <id>{gi:generateId(inv:id, $year, true(), true())}</id>
            <nazev>{inv:text}</nazev>
            <mnozMj>{inv:quantity}</mnozMj>
            <xsl:if test="inv:unit">
                <mj>code:{upper-case(inv:unit)}</mj>
            </xsl:if>
            <xsl:if test="inv:centre/typ:ids">
                <stredisko>code:{upper-case(inv:centre/typ:ids)}</stredisko>
            </xsl:if>
            <xsl:if test="inv:activity/typ:ids">
                <cinnost>code:{upper-case(inv:activity/typ:ids)}</cinnost>
            </xsl:if>
            <xsl:choose>
                <xsl:when
                    test="inv:accounting/typ:ids and inv:accounting/typ:ids != 'Bez' and inv:accounting/typ:ids != 'Ručně'">
                    <typUcOp evidencePath="predpis-zauctovani"
                        >ext:POHODA:{inv:accounting/typ:id}</typUcOp>
                    <kopTypUcOp>false</kopTypUcOp>
                </xsl:when>
                <xsl:otherwise>
                    <kopTypUcOp>true</kopTypUcOp>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="inv:contract">
                <zakazka>code:{upper-case(inv:contract/typ:ids)}</zakazka>
            </xsl:if>
            <typPolozkyK>typPolozky.obecny</typPolozkyK>
            <typSazbyDph>
                <xsl:call-template name="typSazbaDph">
                    <xsl:with-param name="inputDph" select="inv:rateVAT"/>
                </xsl:call-template>
            </typSazbyDph>
            <szbDph>{inv:rateVAT/@value}</szbDph>
            <typCenyDphK>typCeny.bezDph</typCenyDphK>
            <slevaPol>{inv:discountPercentage}</slevaPol>
            <xsl:choose>
                <xsl:when test="inv:foreignCurrency">
                    <cenaMj>{inv:foreignCurrency/typ:unitPrice}</cenaMj>
                    <sumDph>{inv:foreignCurrency/typ:priceVAT}</sumDph>
                </xsl:when>
                <xsl:otherwise>
                    <cenaMj>{inv:homeCurrency/typ:unitPrice}</cenaMj>
                    <sumDph>{inv:homeCurrency/typ:priceVAT}</sumDph>
                </xsl:otherwise>
            </xsl:choose>
        </faktura-vydana-polozka>
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
                <nazFirmy>{inv:partnerIdentity/typ:address/typ:company}</nazFirmy>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>{inv:partnerIdentity/typ:address/typ:name}</nazFirmy>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:for-each select="inv:partnerIdentity/typ:address">
            <ulice>{typ:street}</ulice>
            <mesto>{typ:city}</mesto>
            <psc>{typ:zip}</psc>
            <ic>{typ:ico}</ic>
            <dic>{typ:dic}</dic>
            <kontaktJmeno>{typ:name}</kontaktJmeno>
            <kontaktEmail>{typ:email}</kontaktEmail>
            <kontaktTel>{typ:phone}</kontaktTel>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="summaryForeignCurrency">
        <sumOsvMen>{inv:foreignCurrency/typ:priceSum}</sumOsvMen>
    </xsl:template>

    <xsl:template name="summaryHomeCurrency">
        <sumOsv>{inv:homeCurrency/typ:priceNone}</sumOsv>
        <sumCelkZakl>{inv:homeCurrency/typ:priceHighSum}</sumCelkZakl>
        <sumCelkSniz>{inv:homeCurrency/typ:priceLowSum}</sumCelkSniz>
        <sumCelkSniz2>{inv:homeCurrency/typ:priceThirdSum}</sumCelkSniz2>
        <sumCelkem>{inv:homeCurrency/typ:priceSum}</sumCelkem>
    </xsl:template>

</xsl:stylesheet>
