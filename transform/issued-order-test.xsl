<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:ord="http://www.stormware.cz/schema/version_2/order.xsd"
    xmlns:dc="http://www.dcos.cz/flexi-migration/document-common"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/document-common.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="vat-mapping"/>
    <xsl:param name="year"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:order[(ord:orderDetail)]">
        <objednavka-vydana>
            <bezPolozek>false</bezPolozek>
            <xsl:apply-templates select="ord:orderHeader"/>
            <xsl:apply-templates select="ord:orderDetail"/>
            <xsl:if test="ord:orderSummary/ord:foreignCurrency">
                <mena>code:{upper-case(ord:orderSummary/ord:foreignCurrency/typ:currency/typ:ids)}</mena>
                <kurz>{ord:foreignCurrency/typ:rate}</kurz>
            </xsl:if>
        </objednavka-vydana>
    </xsl:template>
    <!--    Případ, ve kterém objednávka neobsahuje detail, tudíž ani položky-->
    <xsl:template match="lst:invoice[not(ord:orderDetail)]">
        <objednavka-prijata>
            <bezPolozek>true</bezPolozek>
            <xsl:apply-templates select="ord:orderHeader"/>
            <xsl:apply-templates select="ord:orderSummary"/>
            <xsl:if test="ord:orderSummary/ord:foreignCurrency">
                <mena>code:{upper-case(ord:orderSummary/ord:foreignCurrency/typ:currency/typ:ids)}</mena>
                <kurz>{ord:foreignCurrency/typ:rate}</kurz>
            </xsl:if>
        </objednavka-prijata>
    </xsl:template>

    <xsl:template match="ord:orderHeader">
        <!--        Bez migrace číselných řad: -->
        <typDokl>code:OBV</typDokl>
        <!--        Při migraci číselných řad:-->
        <id>{gi:generateId(ord:id, $year, true(), false())}</id>
        <zbyvaUhraditMen>0</zbyvaUhraditMen>
        <kod>{ord:number/typ:numberRequested}</kod>
        <cisDosle>{ord:number/typ:numberRequested}</cisDosle>
        <varSym>{ord:symVar}</varSym>
        <datVyst>{ord:date}</datVyst>
        <datSazbyDph>{ord:dateTax}</datSazbyDph>
        <datTermin>{ord:dateDue}</datTermin>
        <datSplat>{ord:dateDue}</datSplat>
        <popis>{ord:text}</popis>
        <zaokrNaSumK>zaokrNa.zadne</zaokrNaSumK>
        <kontaktJmeno>{ord:partnerIdentity/typ:address/typ:name}</kontaktJmeno>
        <kontaktEmail>{ord:partnerIdentity/typ:address/typ:email}</kontaktEmail>
        <kontaktTel>{ord:partnerIdentity/typ:address/typ:mobilPhone}</kontaktTel>
        <xsl:choose>
            <xsl:when test="ord:partnerIdentity/typ:id">
                <firma>ext:POHODA:{ord:partnerIdentity}</firma>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="adresaFirmy"/>
            </xsl:otherwise>
        </xsl:choose>
        <formaUhradyCis>
            <xsl:choose>
                <xsl:when test="ord:paymentType/typ:ids = 'Příkazem'">9</xsl:when>
                <xsl:when test="ord:paymentType/typ:ids = 'Hotově'">10</xsl:when>
                <xsl:otherwise>7</xsl:otherwise>
            </xsl:choose>
        </formaUhradyCis>
        <xsl:if test="ord:contract">
            <zakazka>code:{upper-case(ord:contract/typ:ids)}</zakazka>
        </xsl:if>

        <xsl:sequence select="dc:insertVatMapping($vat-mapping, current())"/>
        <xsl:if test="ord:centre/typ:ids">
            <stredisko>code:{upper-case(ord:centre/typ:ids)}</stredisko>
        </xsl:if>
        <xsl:if test="ord:activity/typ:ids">
            <cinnost>code:{upper-case(ord:activity/typ:ids)}</cinnost>
        </xsl:if>
    </xsl:template>
    <xsl:template match="ord:orderDetail">
        <polozkyObchDokladu>
            <xsl:apply-templates select="ord:orderItem"/>
        </polozkyObchDokladu>
    </xsl:template>

    <xsl:template match="ord:orderItem">
        <objednavka-vydana-polozka>
            <id>{gi:generateId(ord:id, $year, true(), true())}</id>
            <nazev>{ord:text}</nazev>
            <mnozMj>{ord:quantity}</mnozMj>
            <xsl:if test="ord:unit">
                <mj>code:{upper-case(ord:unit)}</mj>
            </xsl:if>

            <typPolozkyK>typPolozky.obecny</typPolozkyK>
            <typSazbyDph>
                <xsl:call-template name="typSazbaDph">
                    <xsl:with-param name="inputDph" select="ord:rateVAT"/>
                </xsl:call-template>
            </typSazbyDph>
            <szbDph>{ord:rateVAT/@value}</szbDph>

            <xsl:choose>
                <xsl:when test="*:payVAT = 'true'">
                    <typCenyDphK>typCeny.sDph</typCenyDphK>
                </xsl:when>
                <xsl:otherwise>
                    <typCenyDphK>typCeny.bezDph</typCenyDphK>
                </xsl:otherwise>
            </xsl:choose>
            <typCenyDphK>typCeny.bezDph</typCenyDphK>
            <xsl:if test="ord:centre/typ:ids">
                <stredisko>code:{upper-case(ord:centre/typ:ids)}</stredisko>
            </xsl:if>
            <xsl:if test="ord:activity/typ:ids">
                <cinnost>code:{upper-case(ord:activity/typ:ids)}</cinnost>
            </xsl:if>
            <xsl:if test="ord:contract">
                <zakazka>code:{upper-case(ord:contract/typ:ids)}</zakazka>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="ord:foreignCurrency">
                    <cenaMj>{ord:foreignCurrency/typ:unitPrice}</cenaMj>
                    <sumDph>{ord:foreignCurrency/typ:priceVAT}</sumDph>
                    <kurz>{ord:foreignCurrency/typ:rate}</kurz>
                </xsl:when>
                <xsl:otherwise>
                    <cenaMj>{ord:homeCurrency/typ:unitPrice}</cenaMj>
                    <sumDph>{ord:homeCurrency/typ:priceVAT}</sumDph>
                </xsl:otherwise>
            </xsl:choose>
            <slevaPol>{ord:discountPercentage}</slevaPol>
        </objednavka-vydana-polozka>
    </xsl:template>

    <xsl:template match="ord:orderSummary">
        <xsl:choose>
            <xsl:when test="ord:foreignCurrency">
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
    <xsl:template name="adresaFirmy">
        <xsl:choose>
            <xsl:when test="ord:partnerIdentity/typ:address/typ:company">
                <nazFirmy>{ord:partnerIdentity/typ:address/typ:company}</nazFirmy>
            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>{ord:partnerIdentity/typ:address/typ:name}</nazFirmy>
            </xsl:otherwise>
        </xsl:choose>
        <ulice>{ord:partnerIdentity/typ:address/typ:street}</ulice>
        <mesto>{ord:partnerIdentity/typ:address/typ:city}</mesto>
        <psc>{ord:partnerIdentity/typ:address/typ:zip}</psc>
        <ic>{ord:partnerIdentity/typ:address/typ:ico}</ic>
        <dic>{ord:partnerIdentity/typ:address/typ:dic}</dic>
    </xsl:template>
    <xsl:template name="summaryForeignCurrency">
        <sumOsvMen>{ord:foreignCurrency/typ:priceSum}</sumOsvMen>
    </xsl:template>

    <xsl:template name="summaryHomeCurrency">
        <sumZklZakl>{ord:homeCurrency/typ:priceHigh}</sumZklZakl>
        <sumOsv>{ord:homeCurrency/typ:priceNone}</sumOsv>
        <sumCelkZakl>{ord:homeCurrency/typ:priceHighSum}</sumCelkZakl>
        <sumCelkSniz>{ord:homeCurrency/typ:priceLowSum}</sumCelkSniz>
        <sumCelkSniz2>{ord:homeCurrency/typ:priceThirdSum}</sumCelkSniz2>
        <sumZklSniz2>{ord:homeCurrency/typ:price3Sum}</sumZklSniz2>
        <sumZklSniz>{ord:homeCurrency/typ:price2Sum}</sumZklSniz>
        <sumCelkem>{ord:homeCurrency/typ:priceSum}</sumCelkem>
    </xsl:template>

</xsl:stylesheet>
