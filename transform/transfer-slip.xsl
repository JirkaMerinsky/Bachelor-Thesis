<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
                xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
                xmlns:pre="http://www.stormware.cz/schema/version_2/prevodka.xsd" xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:prevodka">
        <skladovy-pohyb>
            <xsl:apply-templates select="pre:prevodkaHeader">
                <xsl:with-param name="mode" select="'output'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="pre:prevodkaDetail">
                <xsl:with-param name="mode" select="'output'"/>
            </xsl:apply-templates>
        </skladovy-pohyb>
        <skladovy-pohyb>
            <xsl:apply-templates select="pre:prevodkaHeader">
                <xsl:with-param name="mode" select="'input'"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="pre:prevodkaDetail">
                <xsl:with-param name="mode" select="'input'"/>
            </xsl:apply-templates>
        </skladovy-pohyb>
    </xsl:template>

    <xsl:template match="pre:prevodkaHeader">
        <xsl:param name="mode"/>
        <xsl:choose>
            <xsl:when test="$mode='input'">
                <id>{gi:generateId(pre:id, $year, true(), false())}</id>
                <typPohybuK showAs="Příjem">typPohybu.prijem</typPohybuK>
                <sklad>code:{pre:store/typ:ids}</sklad>
                <typUcOp>code:PŘEVOD ZBOŽÍ</typUcOp>
                <typPohybuSkladK showAs="Příjem pro převodku">typPohybuSklad.prijemPrevod</typPohybuSkladK>
                <kod>{pre:number/typ:numberRequested}PP</kod>
                <typDokl>code:PŘEVODKA-PŘÍJEM_B</typDokl>
            </xsl:when>
            <xsl:otherwise>
                <id>ext:POHODA:{pre:id}-PV</id>
                <typPohybuK>typPohybu.vydej</typPohybuK>
                <xsl:apply-templates select="../pre:prevodkaDetail" mode="storage"/>
                <typUcOp>code:PŘEVOD ZBOŽÍ</typUcOp>
                <typPohybuSkladK>typPohybuSklad.vydejPrevod</typPohybuSkladK>
                <kod>{pre:number/typ:numberRequested}PV</kod>
                <typDokl>code:PŘEVODKA-VÝDEJ_B</typDokl>
            </xsl:otherwise>
        </xsl:choose>
        <datVyst>{pre:date}</datVyst>
        <poznam>{pre:text}</poznam>
        <popis>{pre:text}</popis>
        <ucetni>true</ucetni>
        <stavSkladK>stavSklad.prevodka</stavSkladK>
        <xsl:choose>
            <xsl:when test="pre:centre">
                <stredisko>code:{pre:centre/typ:ids}</stredisko>
            </xsl:when>
            <xsl:otherwise>
                <stredisko>code:10</stredisko>
            </xsl:otherwise>
        </xsl:choose>


        <xsl:apply-templates select="pre:partnerIdentity"/>
    </xsl:template>

    <xsl:template match="pre:prevodkaDetail">
        <xsl:param name="mode"/>
        <skladovePolozky removeAll="true">
            <xsl:apply-templates select="pre:prevodkaItem">
                <xsl:with-param name="mode" select="$mode"/>
            </xsl:apply-templates>
        </skladovePolozky>
    </xsl:template>

    <xsl:template match="pre:prevodkaItem">

        <xsl:param name="mode"/>
        <skladovy-pohyb-polozka>
            <id>{gi:generateId(pre:id, $year, true(), true())}</id>
            <kod>{pre:stockItem/typ:stockItem/typ:ids}</kod>
            <cenik>code:{upper-case(pre:stockItem/typ:stockItem/typ:ids)}</cenik>
            <typPolozkyK>typPolozky.katalog</typPolozkyK>
            <mnozMj>{pre:quantity}</mnozMj>
            <xsl:choose>
                <xsl:when test="$mode='input'">
                    <sklad>code:{../../pre:prevodkaHeader/pre:store/typ:ids}</sklad>
                    <prevodka>true</prevodka>
                    <mnozMjPrijem>{pre:quantity}</mnozMjPrijem>

                </xsl:when>
                <xsl:otherwise>
                    <sklad>code:{pre:stockItem/typ:store/typ:ids}</sklad>
                    <mnozMjVydej>{pre:quantity}</mnozMjVydej>

                </xsl:otherwise>
            </xsl:choose>
        </skladovy-pohyb-polozka>
    </xsl:template>

    <!-- Get storage id -->
    <xsl:template match="pre:prevodkaDetail" mode="storage">
        <sklad>code:{pre:prevodkaItem/pre:stockItem/typ:store/typ:ids}</sklad>
        <skladCil>code:{../pre:prevodkaHeader/pre:store/typ:ids}</skladCil>
    </xsl:template>

    <xsl:template match="pre:partnerIdentity">
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