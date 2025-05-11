<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd"
    xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd"
    xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd"
    xmlns:inf="http://www.dcos.cz/flexi-migration/invoice-functions"
    xmlns:gi="http://www.dcos.cz/flexi-migration/functions" expand-text="yes">

    <xsl:include href="general/functions.xsl"/>
    <xsl:include href="general/invoice-functions/payment-type.xsl"/>
    <xsl:include href="general/generate-id.xsl"/>
    <xsl:param name="year"/>
    <xsl:output method="xml" version="1.0" indent="yes" encoding="UTF-8"/>

    <xsl:template match="/">
        <winstrom version="1.0" source="Pohoda">
            <xsl:apply-templates/>
        </winstrom>
    </xsl:template>

    <xsl:template match="lAdb:addressbook">
        <xsl:choose>
            <xsl:when test="adb:addressbookHeader/adb:refAddress/typ:refAD">
                <xsl:apply-templates select="adb:addressbookHeader" mode="kontakt"/>
            </xsl:when>
            <xsl:otherwise>
                <adresar>
                    <xsl:apply-templates select="adb:addressbookHeader" mode="firma"/>
                </adresar>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="adb:addressbookHeader" mode="firma">
        <id>ext:POHODA:{adb:id}</id>
        <xsl:variable name="code" select="substring(adb:identity/typ:address/typ:company, 1, 13)"/>
        <xsl:variable name="codeId" select="substring(adb:id, 1, 7)"/>
        <kod>{concat($code, $codeId)}</kod>
        <tel>{adb:phone}</tel>
        <mobil>{adb:mobil}</mobil>
        <fax>{adb:fax}</fax>
        <email>{adb:email}</email>
        <www>{adb:web}</www>
        <typVztahuK>
            <xsl:choose>
                <!-- Solve multiple true and p3 to p6 -->
                <xsl:when test="adb:p1 = 'true'">typVztahu.dodavatel</xsl:when>
                <xsl:when test="adb:p2 = 'true'">typVztahu.odberatel</xsl:when>
                <xsl:when test="adb:p3 = 'true'">typVztahu.vsechno</xsl:when>
                <xsl:when test="adb:p4 = 'true'">typVztahu.vsechno</xsl:when>
                <xsl:when test="adb:p5 = 'true'">typVztahu.vsechno</xsl:when>
                <xsl:when test="adb:p6 = 'true'">typVztahu.vsechno</xsl:when>
            </xsl:choose>
        </typVztahuK>
        <!--        Address-->
        <xsl:apply-templates select="adb:identity/typ:address"/>
        <postovniShodna>true</postovniShodna>
        <!--        Splatnost, in POHODA maturity -->
        <splatDny>{adb:maturity}</splatDny>
        <!--        Forma uhrady -->
        <!--        <xsl:choose>
            <xsl:when test="adb:paymentType/typ:ids = 'Dobírkou'">
                <formaUhradyCis>code:DOBIRKA</formaUhradyCis>
            </xsl:when>
            <xsl:when test="adb:paymentType/typ:ids = 'Příkazem'">
                <formaUhradyCis>code:PREVOD</formaUhradyCis>
            </xsl:when>
            <xsl:when test="adb:paymentType/typ:ids = 'Hotově'">
                <formaUhradyCis>code:HOTOVE</formaUhradyCis>
            </xsl:when>
            <xsl:when test="adb:paymentType/typ:ids = 'Plat.kartou'">
                <formaUhradyCis>code:KARTA</formaUhradyCis>
            </xsl:when>
            <xsl:otherwise>
                <formaUhradyCis>code:NESPECIFIKOVANO</formaUhradyCis>
            </xsl:otherwise>
        </xsl:choose>-->
        <xsl:sequence select="inf:paymentType(adb:paymentType/typ:id)"/>
        <!--        Decide if the subject is paying the VAT-->
        <xsl:apply-templates select="adb:classificationVATIssuedInvoice"/>
        <!--        Centrum-->
        <!--        <xsl:apply-templates select="adb:centre"/>-->

    </xsl:template>

    <xsl:template match="adb:classificationVATIssuedInvoice">
        <platceDph>true</platceDph>
    </xsl:template>

    <!--    <xsl:template match="adb:centre">-->
    <!--        <stredisko>code:<xsl:value-of select="typ:ids"/></stredisko>-->
    <!--    </xsl:template>-->

    <xsl:template match="adb:identity/typ:address">
        <nazev>
            <xsl:choose>
                <xsl:when test="typ:company != ''">{typ:company}</xsl:when>
                <xsl:when test="typ:name != ''">{typ:name}</xsl:when>
                <xsl:otherwise>{typ:street}{typ:city}</xsl:otherwise>
            </xsl:choose>
        </nazev>
        <ulice>{typ:street}</ulice>
        <mesto>{typ:city}</mesto>
        <psc>{typ:zip}</psc>
        <ic>{typ:ico}</ic>
        <dic>>{typ:dic}</dic>
        <xsl:if test="typ:country/typ:ids">
            <stat if-not-found="create">code:{typ:country/typ:ids}</stat>
        </xsl:if>
    </xsl:template>

    <!--    Kontakty-->
    <xsl:template match="adb:addressbookHeader" mode="kontakt">
        <kontakt>
            <firma>ext:POHODA:{adb:refAddress/typ:refAD}</firma>

            <!--                Apply template to split the name -->
            <xsl:call-template name="splitTitles">
                <xsl:with-param name="inputName">{adb:identity/typ:address/typ:name}</xsl:with-param>
            </xsl:call-template>
            <xsl:if test="typ:country/typ:ids">
                <stat if-not-found="create">code:{typ:country/typ:ids}
                </stat>
            </xsl:if>
            <email>{adb:email}</email>
            <mobil>{adb:mobil}</mobil>
            <tel>{adb:phone}</tel>
            <www>{adb:web}</www>
            <fax>{adb:fax}</fax>
            <funkce>{adb:function}</funkce>
            <osloveni>{adb:salutation}</osloveni>
        </kontakt>
    </xsl:template>

    <!--    SPLIT NAME AND TITLE-->
    <xsl:template name="splitTitles">
        <xsl:param name="inputName"/>
        <xsl:param name="separator" select="' '"/>
        <!--        Full name with titles-->
        <xsl:param name="text" select="concat(normalize-space($inputName), $separator)"/>
        <!--        Titul za jmenem-->
        <xsl:choose>
            <xsl:when test="contains($text, ',')">
                <xsl:variable name="titulZa" select="substring-after($text, ',')"/>
                <xsl:choose>
                    <xsl:when
                        test="contains($titulZa, 'Ph.D.') or contains($titulZa, 'MBA') or contains($titulZa, 'CSc')">
                        <titulZa>{$titulZa}</titulZa>
                    </xsl:when>
                    <xsl:otherwise>
                        <titul>{$titulZa}</titul>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="splitName">
                    <xsl:with-param name="inputName" select="substring-before($text, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="splitName">
                    <xsl:with-param name="inputName" select="$text"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="splitName">
        <xsl:param name="inputName"/>
        <xsl:param name="separator" select="' '"/>
        <xsl:param name="text" select="concat(normalize-space($inputName), $separator)"/>
        <xsl:variable name="titulPred" select="substring-before($text, $separator)"/>

        <xsl:choose>
            <!--        Look for title in name-->
            <xsl:when
                test="contains($titulPred, 'Ing.') or contains($titulPred, 'ing.') 
                or contains($titulPred, 'Bc.') or contains($titulPred, 'bc.') 
                or contains($titulPred, 'Mgr.') or contains($titulPred, 'mgr.') 
                or contains($titulPred, 'MUDr.') or contains($titulPred, 'JUDR.') or contains($titulPred, 'PhDr.')">
                <titul>{$titulPred}</titul>
                <xsl:call-template name="splitName">
                    <xsl:with-param name="inputName" select="substring-after($text, $separator)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <jmeno>{substring-before($text, $separator)}</jmeno>
                <prijmeni>{substring-after($text, $separator)}</prijmeni>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
