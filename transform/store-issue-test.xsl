<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:vyd="http://www.stormware.cz/schema/version_2/vydejka.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:vydejka">

        <skladovy-pohyb>
            <xsl:apply-templates select="vyd:vydejkaHeader"/>
            <xsl:apply-templates select="vyd:vydejkaDetail"/>
        </skladovy-pohyb>
    </xsl:template>

    <xsl:template match="vyd:vydejkaHeader">
        <xsl:param name="mode"/>
        <typPohybuSkladK>typPohybuSklad.vydejPrevod</typPohybuSkladK>
        <typDokl>code:VY</typDokl>
        
        <id>{gi:generateId(vyd:id, $year, true(), false())}</id>
        <typPohybuK showAs="Výdej">typPohybu.vydej</typPohybuK>
        <sklad>code:{../vyd:vydejkaDetail/vyd:vydejkaItem/vyd:stockItem/typ:store/typ:ids}</sklad>

        <typUcOp>code:VÝDEJ ZBOŽÍ</typUcOp>
        <kod>{vyd:number/typ:numberRequested}</kod>
        <datVyst>{vyd:date}</datVyst>
        <popis>{vyd:text}</popis>
        <stredisko>code:C</stredisko>


        <xsl:apply-templates select="vyd:partnerIdentity"/>

    </xsl:template>

    <xsl:template match="vyd:vydejkaDetail">
        <xsl:param name="mode"/>
        <skladovePolozky removeAll="true">
            <xsl:apply-templates select="vyd:vydejkaItem"/>
        </skladovePolozky>
    </xsl:template>

    <xsl:template match="vyd:vydejkaItem">


        <xsl:param name="mode"/>
        <skladovy-pohyb-polozka>
            <id>{gi:generateId(vyd:id, $year, true(), true())}</id>
            <kod>{vyd:stockItem/typ:stockItem/typ:ids}</kod>
            <typPolozkyK>typPolozky.obecny</typPolozkyK>
            <mnozMj>{vyd:quantity}</mnozMj>

            <sklad>code:{vyd:stockItem/typ:store/typ:ids}</sklad>
            <prevodka>true</prevodka>
            <mnozMjVydej>{vyd:quantity}</mnozMjVydej>
            <nazev>{vyd:text}</nazev>
            <mj>code:{upper-case(vyd:unit)}</mj>
            <cenaMj>{vyd:homeCurrency/typ:unitPrice}</cenaMj>
            <eanKod>{vyd:stockItem/typ:stockItem/typ:EAN}</eanKod>
        </skladovy-pohyb-polozka>
    </xsl:template>


    <xsl:template match="vyd:partnerIdentity">
        <nazFirmy>{typ:address/typ:company}</nazFirmy>
        <mesto>{typ:address/typ:city}</mesto>
        <psc>{typ:address/typ:zip}</psc>
        <stat>code:{typ:address/typ:country/typ:ids}</stat>
        <ulice>{typ:address/typ:street}</ulice>
        <ic>{typ:address/typ:ico}</ic>
        <dic>{typ:address/typ:dic}</dic>
        <kontakJmeno>{typ:address/typ:name}</kontakJmeno>
        <firma>ext:POHODA:{typ:id}</firma>

    </xsl:template>


</xsl:stylesheet>
