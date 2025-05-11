<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:pri="http://www.stormware.cz/schema/version_2/prijemka.xsd" xmlns:json="http://json.org/"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:param name="journal_pohoda"/>


    <xsl:template match="lst:prijemka">
        <!-- needs to be here because previous accounting year is not closed -->
        <!-- <xsl:if test="not(starts-with(pri:prijemkaHeader/pri:text,'Počáteční'))"> -->
        <skladovy-pohyb json:force-array="true">
            <xsl:apply-templates select="pri:prijemkaHeader"/>
            <xsl:apply-templates select="pri:prijemkaDetail"/>
        </skladovy-pohyb>
        <!-- </xsl:if> -->
    </xsl:template>

    <xsl:template match="pri:prijemkaHeader">
        <id>{gi:generateId(pri:id, $year, true(), false())}</id>
        <typPohybuK showAs="Příjem">typPohybu.prijem</typPohybuK>
        <datVyst>{pri:date}</datVyst>
        <poznam>{pri:text}</poznam>
        <popis>{pri:text}</popis>
        <kod>{pri:number/typ:numberRequested}</kod>

        <!-- <ucetni>true</ucetni>       -->
        <typDokl showAs="STANDARD: Standardní skladový pohyb">code:STANDARD</typDokl>
        <!-- TODO:  -->
        <!--
             <stavSkladK>stavSklad.nefakturovatelne</stavSkladK>
             <typPohybuSkladK>typPohybuSklad.prijemHoly</typPohybuSkladK> -->

        <xsl:choose>
            <xsl:when test="pri:centre">
                <stredisko>code:{upper-case(pri:centre/typ:ids)}</stredisko>
            </xsl:when>
            <xsl:otherwise>
                <stredisko>code:C</stredisko>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="pri:activity">
            <cinnost>code:{upper-case(pri:activity/typ:ids)}"/> </cinnost>
        </xsl:if>

        <xsl:apply-templates select="../pri:prijemkaDetail" mode="storage"/>
        <xsl:apply-templates select="pri:partnerIdentity"/>
    </xsl:template>


    <xsl:template match="pri:prijemkaDetail" mode="storage">
        <sklad>code:{pri:prijemkaItem/pri:stockItem/typ:store/typ:ids}</sklad>
    </xsl:template>

    <xsl:template match="pri:prijemkaDetail">
        <skladovePolozky removeAll="true">
            <xsl:apply-templates select="pri:prijemkaItem"/>
        </skladovePolozky>
    </xsl:template>

    <xsl:template match="pri:prijemkaItem">
        <skladovy-pohyb-polozka>
            <id>{gi:generateId(pri:id, $year, true(), true())}</id>
            <kod>{pri:code}</kod>
            <cenik>code:{upper-case(pri:code)}</cenik>
            <nazev>{pri:text}</nazev>
            <typPolozkyK>typPolozky.katalog</typPolozkyK>
            <mnozMjPrijem>{pri:quantity}</mnozMjPrijem>
            <mnozMj>{pri:quantity}</mnozMj>
            <xsl:if test="pri:centre">
                <stredisko>code:{upper-case(pri:centre/typ:ids)}</stredisko>
            </xsl:if>
            <xsl:if test="pri:activity">
                <cinnost>code:{upper-case(pri:activity/typ:ids)}"/>
                </cinnost>
            </xsl:if>

            <xsl:variable name="slipId" select="../../pri:prijemkaHeader/pri:id"/>
            <xsl:variable name="price" select="pri:homeCurrency/typ:price"/>

            <xsl:variable name="account"
                select="document($journal_pohoda)/items/item[evidenceId = 6 and documentId = $slipId and amount = xs:decimal($price)][1]"/>

            <xsl:choose>

                <xsl:when test="$account and $account != ''">
                    <kopZklMdUcet>false</kopZklMdUcet>
                    <kopZklDalUcet>false</kopZklDalUcet>
                    <zklMdUcet>code:{$account/mdAccount}</zklMdUcet>
                    <zklDalUcet>code:{$account/dAccount}</zklDalUcet>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>ACC_PROBLEM: Zaúčtování položky příjemky neproběhlo. Nenalezeny
                        záznamy v účetním deníku pro položku s kódem {pri:code}
                        />. Číslo příjemky {../../*:prijemkaHeader/*:number/typ:numberRequested}
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>


            <typCenyDphK>
                <xsl:choose>
                    <!-- TODO: vat will be deducted from purchase price type -->
                    <xsl:when test="pri:payVAT = 'true'">typCeny.sDph</xsl:when>
                    <xsl:otherwise>typCeny.bezDph</xsl:otherwise>
                </xsl:choose>
            </typCenyDphK>

            <xsl:choose>
                <xsl:when test="pri:rateVAT = 'third'">
                    <typSzbDphK>typSzbDph.dphSniz2</typSzbDphK>
                </xsl:when>
                <xsl:when test="pri:rateVAT = 'low'">
                    <typSzbDphK>typSzbDph.dphSniz</typSzbDphK>
                </xsl:when>
                <xsl:when test="pri:rateVAT = 'high'">
                    <typSzbDphK>typSzbDph.dphZakl</typSzbDphK>
                </xsl:when>
                <xsl:otherwise>
                    <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>
                </xsl:otherwise>
            </xsl:choose>
            <cenaMj>{pri:homeCurrency/typ:unitPrice}</cenaMj>
            <sklad>code:{pri:stockItem/typ:store/typ:ids}</sklad>
        </skladovy-pohyb-polozka>

    </xsl:template>

    <xsl:template match="pri:partnerIdentity">
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
