<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:vyd="http://www.stormware.cz/schema/version_2/vydejka.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" xmlns:json="http://json.org/"
    expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:param name="journal_pohoda"/>
    <!-- <xsl:param name="stock_pohoda"/> -->

    <xsl:template match="lst:vydejka">
        <skladovy-pohyb json:force-array="true">
            <xsl:apply-templates select="vyd:vydejkaHeader"/>
            <xsl:apply-templates select="vyd:vydejkaDetail"/>
        </skladovy-pohyb>
    </xsl:template>

    <xsl:template match="vyd:vydejkaHeader">
        <id>{gi:generateId(vyd:id, $year, true(), false())}</id>
        <typPohybuK showAs="Výdej">typPohybu.vydej</typPohybuK>
        <datVyst>{vyd:date}</datVyst>
        <poznam>{vyd:text}</poznam>
        <popis>{vyd:text}</popis>
        <kod>{vyd:number/typ:numberRequested}</kod>
        <typDokl>code:STANDARD</typDokl>
        <xsl:choose>
            <xsl:when test="vyd:centre">
                <stredisko>code:{upper-case(vyd:centre/typ:ids)}</stredisko>
            </xsl:when>
            <xsl:otherwise>
                <stredisko>code:C</stredisko>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="vyd:activity">
            <cinnost>code:{upper-case(vyd:activity/typ:ids)}</cinnost>
        </xsl:if>

        <xsl:apply-templates select="../vyd:vydejkaDetail" mode="storage"/>
        <xsl:apply-templates select="vyd:partnerIdentity"/>
    </xsl:template>


    <xsl:template match="vyd:vydejkaDetail" mode="storage">
        <sklad>code:{vyd:vydejkaItem/vyd:stockItem/typ:store/typ:ids}</sklad>
    </xsl:template>

    <xsl:template match="vyd:vydejkaDetail">
        <skladovePolozky removeAll="true">
            <xsl:apply-templates select="vyd:vydejkaItem"/>
        </skladovePolozky>
    </xsl:template>

    <xsl:template match="vyd:vydejkaItem">
        <skladovy-pohyb-polozka>
            <id>{gi:generateId(vyd:id, $year, true(), true())}</id>
            <xsl:variable name="productCode" select="vyd:code"/>
            <kod>{$productCode}</kod>
            <cenik>code:{upper-case($productCode)}</cenik>
            <nazev>{vyd:text}</nazev>
            <typPolozkyK>typPolozky.katalog</typPolozkyK>
            <mnozMjVydej>{vyd:quantity}</mnozMjVydej>
            <mnozMj>{vyd:quantity}</mnozMj>
            <xsl:if test="vyd:centre">
                <stredisko>code:{upper-case(vyd:centre/typ:ids)}</stredisko>
            </xsl:if>
            <xsl:if test="vyd:activity">
                <cinnost>code:{upper-case(vyd:activity/typ:ids)}</cinnost>
            </xsl:if>
            <!-- <xsl:variable name="purchasePrice" select="document($stock_pohoda)/rsp:responsePack/rsp:responsePackItem/lStk:listStock/lStk:stock/stk:stockHeader[stk:code=$productCode]/stk:purchasingPrice"/> -->


            <xsl:variable name="slipId" select="../../vyd:vydejkaHeader/vyd:id"/>
            <!-- <xsl:variable name="price"   select="round( xs:decimal(vyd:quantity)*xs:decimal($purchasePrice) * 100) div 100 "/> -->


            <!-- TODO: MATCH BY PRICE IN CASE OF MULTI DOC  - idk how to do it tho,,,, -->
            <!--  and amount = $price -->
            <xsl:variable name="account"
                select="document($journal_pohoda)/items/item[evidenceId = 7 and documentId = $slipId][1]"/>


            <xsl:choose>
                <xsl:when test="$account and $account != ''">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <zklMdUcet>code:{$account/mdAccount}</zklMdUcet>
                    <zklDalUcet>code:{$account/dAccount}</zklDalUcet>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:message>ACC_PROBLEM: Zaúčtování položky výdejky neproběhlo. Nenalezeny
                        záznamy v účetním deníku pro položku s kódem {$productCode}. Číslo výdejky
                        {../../*:vydejkaHeader/*:number/typ:numberRequested} </xsl:message>
                </xsl:otherwise>
            </xsl:choose>


            <typCenyDphK>
                <xsl:choose>
                    <!-- TODO: vat will be deducted from purchase price type -->
                    <xsl:when test="vyd:payVAT = 'true'">typCeny.sDph</xsl:when>
                    <xsl:otherwise>typCeny.bezDph</xsl:otherwise>
                </xsl:choose>
            </typCenyDphK>

            <xsl:choose>
                <xsl:when test="vyd:rateVAT = 'third'">
                    <typSzbDphK>typSzbDph.dphSniz2</typSzbDphK>
                </xsl:when>
                <xsl:when test="vyd:rateVAT = 'low'">
                    <typSzbDphK>typSzbDph.dphSniz</typSzbDphK>
                </xsl:when>
                <xsl:when test="vyd:rateVAT = 'high'">
                    <typSzbDphK>typSzbDph.dphZakl</typSzbDphK>
                </xsl:when>
                <xsl:otherwise>
                    <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>
                </xsl:otherwise>
            </xsl:choose>
            <cenaMj>{vyd:homeCurrency/typ:unitPrice}</cenaMj>
            <cenaMjProdej>{vyd:homeCurrency/typ:unitPrice}</cenaMjProdej>
            <sklad>code:{vyd:stockItem/typ:store/typ:ids}</sklad>
        </skladovy-pohyb-polozka>

    </xsl:template>

    <xsl:template match="vyd:partnerIdentity">
        <xsl:choose>
            <xsl:when test="typ:id">
                <firma>ext:POHODA:{typ:id}</firma>

            </xsl:when>
            <xsl:otherwise>
                <nazFirmy>{typ:address/typ:company}</nazFirmy>
                <ulice>{typ:address/typ:street}</ulice>
                <mesto>{typ:address/typ:city}</mesto>
                <psc>{typ:address/typ:zip}</psc>
                <ic>{typ:address/typ:ico}</ic>
                <dic>{typ:address/typ:dic}</dic>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="typ:shipToAddress/typ:city">
                <postovniShodna>false</postovniShodna>
                <faNazev>{typ:shipToAddress/typ:company}</faNazev>
                <faNazev2>{typ:shipToAddress/typ:name}</faNazev2>
                <faUlice>{typ:shipToAddress/typ:street}</faUlice>
                <faMesto>{typ:shipToAddress/typ:city}</faMesto>
                <faPsc>{typ:shipToAddress/typ:zip}</faPsc>
            </xsl:when>
            <xsl:otherwise>
                <postovniShodna>true</postovniShodna>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
