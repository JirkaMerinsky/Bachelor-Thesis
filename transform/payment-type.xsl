<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:json="http://json.org/" xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd"
    xmlns:pay="http://www.stormware.cz/schema/version_2/payment.xsd"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lst:payment">
        <forma-uhrady>
            <id>{gi:generateId(pay:id, $year, true(), false())}</id>
            <kod>{upper-case(pay:paymentHeader/pay:name)}</kod>
            <nazev>{pay:paymentHeader/pay:text}</nazev>
            <!--  Nabízet na fakturách  -->
            <vsbFak>true</vsbFak>
            <!--  Nabízet na pokladně   -->
            <vsbPok>true</vsbPok>
            <!--  Nabízet na kase   -->
            <vsbKasa>true</vsbKasa>

            <xsl:if test="pay:paymentHeader/pay:foreignCurrency">
                <!--  Kurz  -->
                <kurz>{pay:paymentHeader/pay:foreignCurrency/pay:rate}</kurz>
                <!--  Kurz. množství  -->
                <kurz>{pay:paymentHeader/pay:foreignCurrency/pay:amount}</kurz>
                <kurzMnozstvi/>
                <!--  Limit vrácení -->
            </xsl:if>


            <!--  Forma úhrady
      převodem - formaUhr.prevod
      hotově - formaUhr.hotove
      složenkou - formaUhr.slozenka
      dobírkou - formaUhr.dobirka
      platební kartou - formaUhr.platKart
      zápočtem - formaUhr.zapocet
      jinou formou - formaUhr.jina
      šekem - formaUhr.sek
      ceninou - formaUhr.cenina  -->
            <xsl:choose>
                <xsl:when test="pay:paymentHeader/pay:name = 'Příkazem'">
                    <formaUhrK>formaUhr.prevod</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Hotově'">
                    <formaUhrK>formaUhr.hotove</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Složenkou'">
                    <formaUhrK>formaUhr.slozenka</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Dobírkou'">
                    <formaUhrK>formaUhr.dobirka</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Plat.kartou'">
                    <formaUhrK>formaUhr.platKart</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Zálohou'">
                    <formaUhrK>formaUhr.jina</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Inkasem'">
                    <formaUhrK>formaUhr.prevod</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Šekem'">
                    <formaUhrK>formaUhr.sek</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Zápočtem'">
                    <formaUhrK>formaUhr.zapocet</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'Stravenka'">
                    <formaUhrK>formaUhr.cenina</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'EUR'">
                    <formaUhrK>formaUhr.jina</formaUhrK>
                </xsl:when>
                <xsl:when test="pay:paymentHeader/pay:name = 'USD'">
                    <formaUhrK>formaUhr.jina</formaUhrK>
                </xsl:when>
            </xsl:choose>

        </forma-uhrady>
    </xsl:template>
</xsl:stylesheet>
