<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:pri="http://www.stormware.cz/schema/version_2/prijemka.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:prijemka">

        <skladovy-pohyb>
            <xsl:apply-templates select="pri:prijemkaHeader"/>
            <xsl:apply-templates select="pri:prijemkaDetail"/>
        </skladovy-pohyb>
    </xsl:template>

    <xsl:template match="pri:prijemkaHeader">
        <xsl:param name="mode"/>
        <typPohybuSkladK>typPohybuSklad.prijemPolot</typPohybuSkladK>
        <!--        Doptat se na typ pohybu!-->
        <typDokl>code:PŘ</typDokl>
        <id>{gi:generateId(pri:id, $year, true(), false())}</id>
        <typPohybuK showAs="Příjem">typPohybu.prijem</typPohybuK>
        <sklad>code:{../pri:prijemkaDetail/pri:prijemkaItem/pri:stockItem/typ:store/typ:ids}</sklad>

        <typUcOp>code:PŘÍJEM ZBOŽÍ</typUcOp>
        <kod>{pri:number/typ:numberRequested}</kod>
        <datVyst>{pri:date}</datVyst>
        <popis>{pri:text}</popis>
        <!--        <stredisko>code:<xsl:value-of select="pri:centre/typ:ids"/></stredisko>-->
        <xsl:if test="pri:centre/typ:ids">
            <stredisko>code:{upper-case(pri:centre/typ:ids)}</stredisko>
        </xsl:if>
        <xsl:if test="pri:activity/typ:ids">
            <cinnost>code:{upper-case(pri:activity/typ:ids)}</cinnost>
        </xsl:if>
        <xsl:apply-templates select="pri:partnerIdentity"/>
    </xsl:template>
    <xsl:template match="pri:prijemkaDetail">
        <xsl:param name="mode"/>
        <skladovePolozky removeAll="true">
            <xsl:apply-templates select="pri:prijemkaItem"/>

        </skladovePolozky>
    </xsl:template>

    <xsl:template match="pri:prijemkaItem">

        <xsl:param name="mode"/>
        <skladovy-pohyb-polozka>
            <id>{gi:generateId(pri:id, $year, true(), true())}</id>
            <kod>{pri:stockItem/typ:stockItem/typ:ids}</kod>
            <cenik>code:{upper-case(pri:stockItem/typ:stockItem/typ:ids)}</cenik>
            <xsl:if test="pri:centre/typ:ids">
                <stredisko>code:{upper-case(pri:centre/typ:ids)}</stredisko>
            </xsl:if>
            <xsl:if test="pri:activity/typ:ids">
                <cinnost>code:{upper-case(pri:activity/typ:ids)}</cinnost>
            </xsl:if>
            <typPolozkyK>typPolozky.katalog</typPolozkyK>
            <mnozMj>{pri:quantity}</mnozMj>

            <sklad>code:{pri:stockItem/typ:store/typ:ids}</sklad>
            <!--            <sklad>code:01</sklad>-->
            <prevodka>true</prevodka>
            <mnozMjPrijem>{pri:quantity}</mnozMjPrijem>

            <nazev>{pri:text}</nazev>
            <mj>code:{upper-case(pri:unit)}</mj>
            <cenaMj>{pri:homeCurrency/typ:unitPrice}</cenaMj>

            <eanKod>{pri:stockItem/typ:stockItem/typ:EAN}</eanKod>
        </skladovy-pohyb-polozka>
    </xsl:template>


    <xsl:template match="pri:partnerIdentity">
        <nazFirmy>{typ:address/typ:company}</nazFirmy>
        <mesto>{typ:address/typ:city}</mesto>
        <psc>{typ:address/typ:zip}</psc>
        <ulice>{typ:address/typ:street}</ulice>
        <ic>{typ:address/typ:ico}</ic>
        <dic>{typ:address/typ:dic}</dic>
        <firma>ext:POHODA:{typ:id}</firma>

    </xsl:template>


</xsl:stylesheet>
